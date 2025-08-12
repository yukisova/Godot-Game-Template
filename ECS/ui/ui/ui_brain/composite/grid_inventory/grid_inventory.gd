## 为了便捷实现目标功能，目前以如下的标准设计:
## 所有物品为矩形，不存在异形物品
@tool
class_name GridInventory
extends MarginContainer

# 背包配置
@export_range(1, 1, 1, "or_greater") var grid_num: int = 1:
	set(v):
		grid_num = v
		if grid_container:
			_generate_grid(grid_num)

@export_range(1, 1, 1, "or_greater") var col_num: int = 1:
	set(v):
		col_num = v
		if grid_container:
			grid_container.columns = col_num
			if !Engine.is_editor_hint():
				_recaculate_grid_index()

@export var panel_prototype: GridInventorySlot:
	set(v):
		panel_prototype = v
		panel_prototype.hide()
@export var mouse_control_enable: bool = true
@export var long_press_duration: float = 0.5 # 长按拿起物品所需时间
@export var rotation_speed: float = 90.0 # 旋转速度 (度/秒)

@onready var grid_container: GridContainer = $GridContainer
@onready var dragable_item_prototype: DragableItem = $PrototypeList/DragableItemPrototype
@onready var item_control: Control = $ItemControl
@onready var pointer: Control = $Pointer

signal focus_item_updated(item: Item)
var last_time_focus_item: DragableItem:
	set(v):
		last_time_focus_item = v
		focus_item_updated.emit(last_time_focus_item.binding_item)

### 用于供下一帧进行参考的上一帧信息
#var last_time_hover: FocusTarget = FocusTarget.new(Vector2i(1,1), Vector2i(-1,-1)):
	#set(v):
		##await clean_vision(last_time_hover)
		#last_time_hover = v
#@onready var focus_target_deafult = FocusTarget.new(Vector2i(1,1), Vector2i(-1,-1))
#class FocusTarget:
	#var tilesize: Vector2i
	#var index: Vector2i
	#
	#func _init(_tilesize: Vector2i, _index: Vector2i) -> void:
		#tilesize = _tilesize
		#index = _index
	#
	#func is_equal(_other: FocusTarget) -> bool:
		#return tilesize == _other.tilesize and index == _other.index
	#

## 存放的字典
var dict: Dictionary[Vector2i, GridInventorySlot] = {}
var items_in_inventory: Array[DragableItem] = []

# 交互状态管
enum InteractionState {
	IDLE, ## 正常
	HOVERING, ## 点击 -> 拿起的过程 
	HOLDING, ## 拿起
	ROTATING ## 旋转
}
var interaction_state: InteractionState = InteractionState.IDLE
var current_held_item: DragableItem = null ## 当前所拿起的物品
var press_time: float = 0.0 ## 长按的起始时间
var current_rotation: float = 0.0 ## 当前的旋转
var highlight_timer: float = 0.0 ## 长按的时间

func _ready():
	# 初始化时隐藏原型
	if Engine.is_editor_hint(): return
	item_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel_prototype.hide()
	dragable_item_prototype.hide()
	
	## 确保目标GridContainer设置了col_num
	col_num = col_num
	## 生成网格
	_generate_grid(grid_num)
	pointer.hide() # 初始隐藏指针

func _generate_grid(v: int):
	# 1. 清除现有格子
	for child in grid_container.get_children():
		if child != panel_prototype:
			child.queue_free()
	
	# 2. 刷新格子
	for i in range(v):
		var panel = panel_prototype.duplicate() as GridInventorySlot
		grid_container.add_child(panel)
		panel.show()
	if !Engine.is_editor_hint():
		_recaculate_grid_index()

## 遍历更新网格的索引
func _recaculate_grid_index():
	## 1. 将旧索引字典进行重置
	dict.clear()
	
	var children = grid_container.get_children()
	for i in range(children.size()):
		var child = children[i]
		if child is GridInventorySlot:
			# 计算行列索引
			@warning_ignore("integer_division")
			var row:int = i / col_num
			var col:int = i % col_num
			child.current_index = Vector2i(row, col)
			dict[child.current_index] = child
		else:
			push_error("不允许在GridInventory中插入非GridInventorySlot类节点")

## 检查区域是否可用 
func is_area_available(start_index: Vector2i, _size: Vector2i) -> bool:
	for col in range(_size.x):
		for row in range(_size.y):
			var index = start_index + Vector2i(row, col)
			if not dict.has(index): # 超出边界
				return false
			if dict[index].linkage_dragable != null:
				return false
	return true

## 放置物品
func place_item(item: DragableItem, start_index: Vector2i) -> bool:
	var _size = item.binding_item.item_tilesize
	if not is_area_available(start_index, _size):
		return false
	
	# 更新所有占用格子
	for col in range(_size.x):
		for row in range(_size.y):
			var index = start_index + Vector2i(row, col)
			dict[index].linkage_dragable = item
	
	# 设置物品位置
	item.global_position = dict[start_index].global_position
	item.current_slot = dict[start_index]
	item.origin_slot = dict[start_index]
	items_in_inventory.append(item)
	return true


	
# 移除物品
func remove_item(item: DragableItem):
	if item in items_in_inventory:
		items_in_inventory.erase(item)
	
	# 清除所有占用格子
	for slot in dict.values():
		if slot:
			if slot.linkage_dragable == item:
				slot.linkage_dragable = null
	
	item.current_slot = null

# 自动整理背包
func auto_organize():
	# 先移除所有物品
	var items = items_in_inventory.duplicate()
	for item in items:
		remove_item(item)
	
	# 按物品大小排序（大物品优先）
	items.sort_custom(func(a, b): return a.binding_item.grid_value > b.binding_item.grid_value)
	
	# 重新放置物品
	for item in items:
		var placed = false
		for slot in dict.values():
			if slot.linkage_dragable == null:
				if place_item(item, slot.current_index):
					placed = true
					break
		if not placed:
			push_warning("无法放置物品: " + item.binding_item.item_name)

func add_item(item_data: Item) -> bool:
	# 1. 创建DragableItem实例
	var new_item: DragableItem = dragable_item_prototype.duplicate()
	new_item.binding_item = item_data
	new_item.visible = true
	item_control.add_child(new_item)  # 添加到临时容器
	
	await get_tree().process_frame
	
	var grid_size = new_item.binding_item.item_tilesize
	
	# 3. 搜索可用位置 (从左到右，从上到下)
	var placed = false
	for slot in dict.values():
		if slot:
			if is_area_available(slot.current_index, grid_size):
				# 4. 放置物品并更新状态
				place_item(new_item, slot.current_index)
				placed = true
				break
	
	# 5. 处理放置失败
	if not placed:
		new_item.queue_free()
		push_error("背包空间不足，无法添加物品: " + item_data.item_name)
		return false
	
	return true

## 获取当前鼠标下的格子
func get_slot_under_mouse() -> GridInventorySlot:
	var mouse_pos = get_global_mouse_position()
	for slot in grid_container.get_children():
		if slot is GridInventorySlot and slot.get_global_rect().has_point(mouse_pos):
			return slot
	return null

func get_nearest_slot(mouse_pos: Vector2) -> GridInventorySlot:
	# 1. 创建二维KD树索引（提高搜索效率）
	var slot_positions = []
	for slot in grid_container.get_children():
		if slot is GridInventorySlot:
			var slot_rect = slot.get_global_rect()
			slot_positions.append({
				"position": slot_rect.position + slot_rect.size/2,
				"slot": slot
			})
	
	# 2. 快速找到最近格子
	if slot_positions.is_empty():
		return null
	
	var min_distance = INF
	var nearest_slot = null
	
	for slot_data in slot_positions:
		var distance = slot_data["position"].distance_to(mouse_pos)
		if distance < min_distance:
			min_distance = distance
			nearest_slot = slot_data["slot"]
	
	return nearest_slot

## 获取当前鼠标下的物品
func get_item_under_mouse() -> DragableItem:
	var mouse_pos = get_global_mouse_position()
	for item in items_in_inventory:
		if item.get_global_rect().has_point(mouse_pos):
			return item
	return null

## 开始拿起物品
func pick_up_item(item: DragableItem):
	if item and item.current_slot:
		interaction_state = InteractionState.HOLDING
		current_held_item = item
		remove_item(item)
		item.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item.z_index = 10 # 提高层级确保在最上层
		current_rotation = item.rotation

## 放下物品
func drop_item():
	if not current_held_item: return
	
	var target_slot = get_slot_under_mouse()
	if not target_slot:
		target_slot = get_nearest_slot(pointer.global_position)
	
	if target_slot and place_item(current_held_item, target_slot.current_index):
		## 成功放下
		current_held_item.mouse_filter = Control.MOUSE_FILTER_IGNORE
		#current_held_item.z_index = 0
	else:
		## 放下失败，放回原处
		if current_held_item.origin_slot:
			place_item(current_held_item, current_held_item.origin_slot.current_index)
			
	current_held_item = null
	interaction_state = InteractionState.IDLE

### 预览目标区域
#func drop_item_vision():
	## 1. 确定当前聚焦的物品尺寸
	#var source_tilesize: Vector2i
	#var current_item = current_held_item if current_held_item else get_item_under_mouse()
	#
	#if current_item:
		#source_tilesize = current_item.binding_item.item_tilesize
	#else:
		#source_tilesize = Vector2i(1,1)
	#
	## 2. 获取目标格子
	#var target_slot = get_slot_under_mouse()
	#if not target_slot and current_held_item:
		#target_slot = get_nearest_slot(pointer.global_position)
	#
	## 3. 创建当前帧的聚焦目标
	#var this_time_hover = FocusTarget.new(source_tilesize, target_slot.current_index if target_slot else Vector2i(-1,-1))
	#
	## 4. 状态变化时更新预览
	#if !this_time_hover.is_equal(last_time_hover):
		#if target_slot:
			#place_item_vision(this_time_hover)
		#last_time_hover = this_time_hover
	#
	## 5. 没有有效目标时清除预览
	#if not target_slot:
		#last_time_hover = focus_target_deafult
#
	#
#func place_item_vision(focus_target: FocusTarget):
	#var tilesize = focus_target.tilesize
	#var start_index = focus_target.index
	#var target_color = Color.GREEN
	#
	#if not is_area_available(start_index, tilesize):
		#target_color = Color.RED
	#
	## 添加视觉动画效果
	#var tween = create_tween()
	#for col in range(tilesize.x):
		#for row in range(tilesize.y):
			#var index = start_index + Vector2i(row, col)
			#if dict.has(index):
				#var slot = dict[index]
				#tween.parallel().tween_property(slot, "self_modulate", target_color, 0.1)
#
#func clean_vision(focus_target: FocusTarget):
	#if focus_target.is_equal(focus_target_deafult): 
		#return
		#
	#var tilesize = focus_target.tilesize
	#var start_index = focus_target.index
	#
	## 只清除实际存在的格子
	#for col in range(tilesize.x):
		#for row in range(tilesize.y):
			#var index = start_index + Vector2i(row, col)
			#if dict.has(index):
				## 恢复默认颜色（无滤镜）
				#dict[index].self_modulate = Color(1, 1, 1, 1)



## 旋转当前手持物品
func rotate_held_item():
	if not current_held_item: return
	
	# 旋转物品
	current_rotation += deg_to_rad(rotation_speed) * get_process_delta_time()
	current_held_item.rotation = fmod(current_rotation, TAU)
	
	# 更新物品尺寸（如果需要）
	var rotated_size = Vector2i(
		current_held_item.binding_item.item_tilesize.y,
		current_held_item.binding_item.item_tilesize.x
	)
	current_held_item.custom_minimum_size = Vector2(64, 64) * rotated_size
	current_held_item.size = current_held_item.custom_minimum_size

func _process(delta):
	if not mouse_control_enable or Engine.is_editor_hint():
		return
	
	pointer.global_position = pointer.get_global_mouse_position()
	
	match interaction_state:
		InteractionState.IDLE:
			pointer.hide()
			var item = get_item_under_mouse()
			if item:
				interaction_state = InteractionState.HOVERING
				pointer.show()
				#pointer.texture = load("res://ui/hover_pointer.png") # 悬停样式
				highlight_timer = 0.0
			else:
				pointer.hide()
		InteractionState.HOVERING:
			
			highlight_timer += delta
			var item = get_item_under_mouse()
			
			if not item:
				interaction_state = InteractionState.IDLE
				pointer.hide()
				return
			
			
			# 显示长按进度
			#pointer.modulate = Color(1, 1, 1, clamp(highlight_timer / long_press_duration, 0.3, 1.0))
			
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				last_time_focus_item = item
				press_time += delta
			else:
				press_time = 0
			
			
			# 长按时间达到
			if press_time >= long_press_duration:
				pick_up_item(item)
				#pointer.texture = load("res://ui/hold_pointer.png") # 拿起样式
				pointer.modulate = Color(1, 1, 1, 1)
		InteractionState.HOLDING:
			## 3.0. 如果当前没有抓住物品，则说明目标格子不存在物品，可以直接回退到IDLE状态
			if not current_held_item:
				interaction_state = InteractionState.IDLE
				pointer.hide()
				return
			
			# 3.2. 物品跟随鼠标
			current_held_item.global_position = pointer.global_position - current_held_item.size / 2
			
			# 3.3. 显示放置区域预览
			pointer.show()
			
			# 3.4. 如果在此时按下按键，可以旋转物品
			if Input.is_key_pressed(KEY_8):
				rotate_held_item()
	
	# 松开鼠标放下物品
	if interaction_state == InteractionState.HOLDING and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		drop_item()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_9 and event.is_pressed():
			print("背包物品状态:")
			for item in items_in_inventory:
				print("物品%s的起始存放位置%s" % [item.binding_item.item_name, item.current_slot.current_index])
