## 网格背包系统 - 高级拖拽式物品管理界面
##
## 该组件实现了一个功能完整的网格背包系统，提供直观的拖拽式物品管理体验。
## 支持复杂的物品布局、智能碰撞检测和丰富的交互功能。
## [br][b]编辑者:[/b] Sora
@tool
class_name GridInventory
extends MarginContainer

#region 网格配置

## 网格槽位总数
## 决定背包的容量大小，最小值为1。
@export_range(1, 1, 1, "or_greater") var grid_num: int = 1:
	set(v):
		grid_num = v
		if grid_container:
			_generate_grid(grid_num)

## 网格列数
## 决定背包的布局形状，影响行列数量。
@export_range(1, 1, 1, "or_greater") var col_num: int = 1:
	set(v):
		col_num = v
		if grid_container:
			grid_container.columns = col_num
			if !Engine.is_editor_hint():
				_recaculate_grid_index()

## 网格槽位原型
## 用于生成所有网格槽位的模板组件，类型为 [GridInventorySlot]。
@export var panel_prototype: GridInventorySlot:
	set(v):
		panel_prototype = v
		if panel_prototype:
			panel_prototype.hide()

## 按钮容器弹出场景
## 用于创建物品交互菜单的场景模板，类型为 [PackedScene]。
@export var button_container_popum: PackedScene:
	set(v):
		if v:
			var scene = v.instantiate()
			if scene is ButtonContainer:
				button_container_popum = v
			scene.queue_free()

## 绑定的状态组件
## 与背包系统关联的角色状态组件，类型为 [CStatusList]。
var binding_status: CStatusList

## 当前按钮容器
## 已经存在的按钮容器实例，类型为 [ButtonContainer]。
var button_container: ButtonContainer:
	set(v):
		if button_container:
			button_container.queue_free()
		button_container = v

#endregion

#region 交互配置

## 是否启用鼠标控制
## 控制是否响应鼠标拖拽操作。
@export var mouse_control_enable: bool = true

## 长按拾取持续时间
## 玩家需要长按多长时间才能拾取物品（秒）。
@export var long_press_duration: float = 0.5

## 物品旋转速度
## 物品旋转时的角速度（度/秒）。
@export var rotation_speed: float = 90.0
#endregion

#region 场景节点引用

## 网格容器
## 存放所有网格槽位的容器组件，类型为 [GridContainer]。

@export_group("依赖")
@export var grid_container: GridContainer

## 可拖拽物品原型
## 用于创建新物品实例的模板组件，类型为 [DragableItem]。
@export var dragable_item_prototype: DragableItem

## 物品控制容器
## 管理所有可拖拽物品显示的容器，类型为 [Control]。
@export var item_control: Control

## 鼠标指针
## 显示当前鼠标位置和状态的指示器，类型为 [Control]。
@export var pointer: Control

## 按钮容器控制节点
## [ButtonContainer] 生成之后的默认父节点，类型为 [Control]。
@export var button_container_control: Control

## 水平容器
## 用于放置装备控制节点和按钮容器节点的容器，类型为 [HBoxContainer]。
@export var hbox_container: HBoxContainer

## 装备控制节点
## 装备控制节点，类型为 [EquipmentControl]。
var equipment_control: EquipmentControl:
	set(v):
		if equipment_control:
			equipment_control.queue_free()
		equipment_control = v
		if equipment_control:
			hbox_container.add_child(equipment_control)

#endregion

#region 信号系统

## 焦点物品更新信号
## 当用户选择不同物品时发出，用于更新物品详情显示。
## [param item]: 新选中的物品，类型为 [Item]
signal focus_item_updated(item: Item)

## 上次聚焦的物品
## 自动发出焦点更新信号，类型为 [DragableItem]。
var last_time_focus_item: DragableItem:
	set(v):
		last_time_focus_item = v
		if v and v.binding_item:
			focus_item_updated.emit(v.binding_item)

#endregion

#region 数据存储

## 网格槽位字典
## 存储网格索引与槽位组件的映射关系。
## 键为网格索引（[Vector2i]），值为对应的槽位组件（[GridInventorySlot]）。
var dict: Dictionary[Vector2i, GridInventorySlot] = {}

## 背包中的物品列表
## 存储当前背包中所有的可拖拽物品，类型为 [Array] of [DragableItem]。
var items_in_inventory: Array[DragableItem] = []

#endregion

#region 交互状态管理

## 交互状态枚举
## 定义用户与背包系统的不同交互模式。
enum InteractionState {
	IDLE,      ## 空闲状态：无交互
	HOVERING,  ## 悬停状态：鼠标悬停在物品上
	HOLDING,   ## 持有状态：正在拖拽物品
	ROTATING   ## 旋转状态：正在旋转物品
}

## 当前交互状态
## 记录当前的用户交互模式，类型为 [enum InteractionState]。
var interaction_state: InteractionState = InteractionState.IDLE

## 当前持有的物品
## 正在被拖拽的物品实例，类型为 [DragableItem]。
var current_held_item: DragableItem = null

## 按压时间计时器
## 用于检测长按操作的累计时间。
var press_time: float = 0.0

## 当前旋转角度
## 物品旋转时的累计角度（弧度）。
var current_rotation: float = 0.0

## 高亮计时器
## 用于悬停效果的时间累计。
var highlight_timer: float = 0.0

#endregion

#region 预览系统

## 预览高亮槽位列表
## 存储当前预览状态下需要高亮显示的槽位，类型为 [Array] of [GridInventorySlot]。
var preview_highlight_slots: Array[GridInventorySlot] = []
var preview_highlight_bullet_slots: Array[BulletClipSlot] = []

## 预览状态标志
## 标记当前是否处于预览模式。
var is_previewing: bool = false

#endregion

#region 组件初始化

## 组件准备就绪
## 初始化网格布局和原型组件。
func _ready() -> void:
	# 编辑器模式下不执行运行时逻辑
	if Engine.is_editor_hint(): 
		return
	
	print("网格背包: 开始初始化")
	
	# 设置基础组件状态
	item_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel_prototype.hide()
	dragable_item_prototype.hide()
	pointer.hide()
	
	
	print("网格背包: 初始化完成，网格数量: ", grid_num, ", 列数: ", col_num)

#endregion

#region 网格管理

## 生成网格槽位
## 根据指定数量生成网格槽位组件。
## [param v]: 要生成的槽位数量
func _generate_grid(v: int):
	print("网格背包: 生成网格，槽位数量: ", v)
	
	# 清除现有的槽位（保留原型）
	for child in grid_container.get_children():
		if child != panel_prototype:
			child.queue_free()
	
	# 创建新的槽位
	for i in range(v):
		var panel = panel_prototype.duplicate() as GridInventorySlot
		grid_container.add_child(panel)
		panel.show()
	
	# 运行时模式下重新计算索引
	if !Engine.is_editor_hint():
		_recaculate_grid_index()

## 重新计算网格索引
## 遍历所有槽位并更新其二维坐标索引。
func _recaculate_grid_index():
	print("网格背包: 重新计算网格索引")
	
	# 清空索引字典
	dict.clear()
	
	var children = grid_container.get_children()
	for i in range(children.size()):
		var child = children[i]
		if child is GridInventorySlot:
			# 计算二维网格坐标
			@warning_ignore("integer_division")
			var row: int = i / col_num 
			var col: int = i % col_num
			child.current_index = Vector2i(row, col)
			print("网格背包: 计算网格索引: ", child.current_index, col_num)
			dict[child.current_index] = child
		else:
			push_error("网格背包: 检测到非法子节点类型: " + str(type_string(typeof(child))))

#endregion

#region 区域检测和验证

## 检查区域是否可用
## 判断指定区域是否可以放置物品。
## [param start_index]: 起始网格坐标，类型为 [Vector2i]
## [param _size]: 物品占用的网格尺寸，类型为 [Vector2i]
## [br][br][b]返回:[/b] [bool] 该区域是否可以放置物品
func is_area_available(start_index: Vector2i, _size: Vector2i) -> bool:
	# 检查每个被占用的网格槽位
	for col in range(_size.x):
		for row in range(_size.y):
			var index = start_index + Vector2i(row, col)
			# 检查是否超出边界
			if not dict.has(index): 
				return false
			# 检查槽位是否已被占用
			if dict[index].linkage_dragable != null:
				return false
	return true

## 获取区域覆盖的所有槽位
## 返回指定区域覆盖的所有槽位列表。
## [param start_index]: 起始网格坐标，类型为 [Vector2i]
## [param _size]: 物品占用的网格尺寸，类型为 [Vector2i]
## [br][br][b]返回:[/b] [Array] of [GridInventorySlot] 该区域覆盖的所有槽位列表
func get_area_slots(start_index: Vector2i, _size: Vector2i) -> Array[GridInventorySlot]:
	var slots: Array[GridInventorySlot] = []
	
	for col in range(_size.x):
		for row in range(_size.y):
			var index = start_index + Vector2i(row, col)
			if dict.has(index):
				slots.append(dict[index])
	
	return slots

#endregion

#region 物品操作

## 放置物品
## 将物品放置到指定的网格位置。
## [param item]: 要放置的可拖拽物品，类型为 [DragableItem]
## [param start_index]: 起始网格坐标，类型为 [Vector2i]
## [br][br][b]返回:[/b] [bool] 是否成功放置
func place_item(item: DragableItem, start_index: Vector2i) -> bool:
	var _size = item.item_size
	
	# 检查区域是否可用
	if not is_area_available(start_index, _size):
		return false
	
	# 更新所有占用格子
	for col in range(_size.x):
		for row in range(_size.y):
			var index = start_index + Vector2i(row, col)
			dict[index].linkage_dragable = item
	
	# 设置物品位置和状态
	item.global_position = dict[start_index].global_position
	item.current_slot = dict[start_index]
	item.origin_slot = dict[start_index]
	items_in_inventory.append(item)
	
	print("网格背包: 成功放置物品 ", item.binding_item.item_name, " 在位置 ", start_index)
	return true

## 移除物品
## 从背包中移除指定的物品。
## [param item]: 要移除的可拖拽物品，类型为 [DragableItem]
func remove_item(item: DragableItem):
	if item in items_in_inventory:
		items_in_inventory.erase(item)
	
	# 清除所有占用格子
	for slot in dict.values():
		if slot and slot.linkage_dragable == item:
			slot.linkage_dragable = null
	
	item.current_slot = null
	print("网格背包: 移除物品 ", item.binding_item.item_name)

## 自动整理背包
## 按照物品大小重新排列所有物品，大物品优先放置。
func auto_organize():
	print("网格背包: 开始自动整理")
	
	# 先移除所有物品
	var items = items_in_inventory.duplicate()
	for item in items:
		remove_item(item)
	
	# 按物品大小排序（大物品优先）
	items.sort_custom(func(a, b): return a.binding_item.get_grid_value() > b.binding_item.get_grid_value())
	
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
	
	print("网格背包: 自动整理完成")

## 添加物品到背包
## 尝试将新物品添加到背包中的可用位置。
## [param item_data]: 要添加的物品数据，类型为 [Item]
## [br][br][b]返回:[/b] [bool] 是否成功添加
func add_item(item_data: Item) -> bool:
	print("网格背包: 尝试添加物品 ", item_data.item_name)
	
	# 1. 创建DragableItem实例
	var new_item: DragableItem = dragable_item_prototype.duplicate()
	new_item.binding_item = item_data
	new_item.visible = true
	item_control.add_child(new_item)  # 添加到临时容器
	
	await get_tree().process_frame
	
	var grid_size = new_item.item_size
	
	# 3. 搜索可用位置 (从左到右，从上到下)
	var placed = false
	for slot in dict.values():
		if slot and is_area_available(slot.current_index, grid_size):
			# 4. 放置物品并更新状态
			place_item(new_item, slot.current_index)
			placed = true
			break
	
	# 5. 处理放置失败
	if not placed:
		new_item.queue_free()
		push_error("背包空间不足，无法添加物品: " + item_data.item_name)
		return false
	
	print("网格背包: 成功添加物品 ", item_data.item_name)
	return true

#endregion

#region 鼠标交互检测

## 获取当前鼠标下的格子
## 检测鼠标位置下方的网格槽位。
## [br][br][b]返回:[/b] [GridInventorySlot] 鼠标下方的网格槽位，如果没有则返回null
func get_slot_under_mouse() -> GridInventorySlot:
	var mouse_pos = get_global_mouse_position()
	for slot in grid_container.get_children():
		if slot is GridInventorySlot and slot.get_global_rect().has_point(mouse_pos):
			return slot
	return null

## 获取当前鼠标下的弹仓槽位
func get_bullet_slot_under_mouse() -> BulletClipSlot:
	var mouse_pos = get_global_mouse_position()
	if equipment_control:
		for slot in equipment_control.bullet_clip_array:
			if slot.get_global_rect().has_point(mouse_pos):
				return slot
		return null
	else:
		return null
		

## 获取最近的网格槽位
## 计算距离指定位置最近的网格槽位。
## [param mouse_pos]: 鼠标位置，类型为 [Vector2]
## [br][br][b]返回:[/b] [GridInventorySlot] 距离鼠标最近的网格槽位
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
## 检测鼠标位置下方的可拖拽物品。
## [br][br][b]返回:[/b] [DragableItem] 鼠标下方的可拖拽物品，如果没有则返回null
func get_item_under_mouse() -> DragableItem:
	var mouse_pos = get_global_mouse_position()
	for item in items_in_inventory:
		if item.get_global_rect().has_point(mouse_pos):
			return item
	return null

#endregion

#region 拖拽操作

## 开始拿起物品
## 开始拖拽指定的物品。
## [param item]: 要拿起的可拖拽物品，类型为 [DragableItem]
func pick_up_item(item: DragableItem):
	if item and item.current_slot:
		interaction_state = InteractionState.HOLDING
		current_held_item = item
		remove_item(item)
		item.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item.z_index = 10 # 提高层级确保在最上层
		current_rotation = item.rotation
		print("网格背包: 拿起物品 ", item.binding_item.item_name)

## 放下物品
## 尝试将当前持有的物品放置到目标位置。
## 有两种情况: 放到网格中或者放到弹仓中
func drop_item():
	if not current_held_item: 
		return
	## 1. 首先检查是否可以放到弹仓中
	var target_slot = get_slot_under_mouse()
	var target_bullet_slot = get_bullet_slot_under_mouse()

	if not target_slot and not target_bullet_slot:
		target_slot = get_nearest_slot(pointer.global_position)

	if not target_bullet_slot:
		if target_slot and place_item(current_held_item, target_slot.current_index):
			## 成功放下
			current_held_item.mouse_filter = Control.MOUSE_FILTER_IGNORE
			current_held_item.z_index = 0
			print("网格背包: 成功放下物品 ", current_held_item.binding_item.item_name)
		else:
			## 放下失败，放回原处
			if current_held_item.origin_slot:
				place_item(current_held_item, current_held_item.origin_slot.current_index)
				print("网格背包: 放下失败，物品已放回原处")
	else:
		## 如果鼠标下有弹仓槽位，则可以尝试填装子弹
		if target_bullet_slot.try_reload_bullet(current_held_item):
			current_held_item.queue_free()
			print("弹仓: 成功填装子弹", current_held_item.binding_item.item_name)
		else:
			## 放下失败，放回原处
			if current_held_item.origin_slot:
				place_item(current_held_item, current_held_item.origin_slot.current_index)
				print("弹仓: 尝试填装失败，物品已放回原处")
			
	current_held_item = null
	interaction_state = InteractionState.IDLE

## 预览目标区域
## 显示当前物品可以放置的位置预览。
func drop_item_vision():
	if not current_held_item:
		return
	
	# 清除之前的预览
	clear_preview()
	
	var target_slot = get_slot_under_mouse()
	var target_bullet_slot = get_bullet_slot_under_mouse()

	if not target_slot and not target_bullet_slot:
		target_slot = get_nearest_slot(pointer.global_position)
	
	if not target_bullet_slot:
		if target_slot:
			var item_size = current_held_item.item_size
			
			# 检查该位置是否可用
			if is_area_available(target_slot.current_index, item_size):
				# 获取预览区域的所有槽位
				preview_highlight_slots = get_area_slots(target_slot.current_index, item_size)
				
				# 高亮显示可用区域（绿色）
				for slot in preview_highlight_slots:
					slot.modulate = Color(0.5, 1.0, 0.5, 0.8)  # 半透明绿色
				
			else:
				# 高亮显示不可用区域（红色）
				preview_highlight_slots = get_area_slots(target_slot.current_index, item_size)
				
				for slot in preview_highlight_slots:
					if dict.has(slot.current_index):
						slot.modulate = Color(1.0, 0.5, 0.5, 0.8)  # 半透明红色
			is_previewing = true
	else:
		if target_bullet_slot.is_empty():
			preview_highlight_bullet_slots.append(target_bullet_slot)
			target_bullet_slot.modulate = Color(0.5, 1.0, 0.5, 0.8)
		else:
			preview_highlight_bullet_slots.append(target_bullet_slot)
			target_bullet_slot.modulate = Color(1.0, 0.5, 0.5, 0.8)
		is_previewing = true

## 清除预览效果
## 恢复所有槽位的正常显示状态。
func clear_preview():
	if is_previewing:
		for slot in preview_highlight_slots:
			slot.modulate = Color.WHITE  # 恢复正常颜色
		
		for slot in preview_highlight_bullet_slots:
			slot.modulate = Color.WHITE

		preview_highlight_bullet_slots.clear()
		preview_highlight_slots.clear()
		is_previewing = false

#endregion

#region 物品旋转

## 旋转当前手持物品
## 在拖拽过程中旋转物品的显示方向。
func rotate_held_item():
	if not current_held_item: 
		return
	
	# 检查物品是否可以旋转（1x1的物品旋转没有意义）
	if current_held_item.binding_item.item_tilesize.x == current_held_item.binding_item.item_tilesize.y:
		return
	
	# 离散旋转：每次旋转90度
	current_rotation += deg_to_rad(90.0)
	current_held_item.rotation = fmod(current_rotation, TAU)
	
	# 更新物品的实际网格尺寸（交换宽度和高度）
	var original_size = current_held_item.binding_item.item_tilesize
	var rotated_size = Vector2i(original_size.y, original_size.x)
	current_held_item.binding_item.item_tilesize = rotated_size
	
	# 更新物品的显示尺寸
	current_held_item.custom_minimum_size = Vector2(80, 80) * Vector2(rotated_size)
	current_held_item.size = current_held_item.custom_minimum_size
	
	# 更新物品的内部尺寸状态
	current_held_item.item_size = rotated_size
	current_held_item.is_rotated = !current_held_item.is_rotated
	
	print("网格背包: 旋转物品 ", current_held_item.binding_item.item_name, " 尺寸从 ", original_size, " 变为 ", rotated_size)

#endregion

#region 主循环处理

func _process(delta):
	if not mouse_control_enable or Engine.is_editor_hint():
		return
	
	pointer.global_position = pointer.get_global_mouse_position()
	
	# 检查是否有button_container存在，如果存在则检查鼠标是否在button_container区域内
	if _is_mouse_over_button_container():
		pointer.hide()
		return
	
	match interaction_state:
		InteractionState.IDLE:
			pointer.hide()
			var item = get_item_under_mouse()
			if item:
				interaction_state = InteractionState.HOVERING
				pointer.show()
				highlight_timer = 0.0
				
				# 如果鼠标点击了物品，直接选择
				if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
					last_time_focus_item = item
					press_time += delta
				elif press_time != 0:
					_select_item(item, pointer.global_position)
					press_time = 0
			else:
				if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
					button_container = null
				pointer.hide()
				press_time = 0
				
		InteractionState.HOVERING:
			highlight_timer += delta
			var item = get_item_under_mouse()
			
			if not item:
				interaction_state = InteractionState.IDLE
				pointer.hide()
				return
			
			# 检查是否有button_container存在且鼠标在其区域内
			if _is_mouse_over_button_container():
				# 鼠标在button_container区域内，暂停交互
				pointer.hide()
				return
			
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				last_time_focus_item = item
				press_time += delta
			elif press_time != 0:
				# 如果当前物品与之前选择的物品不同，直接切换选择:
				_select_item(item, get_item_under_mouse().global_position+get_item_under_mouse().size / 2)
			else:
				press_time = 0
			
			# 长按时间达到
			if press_time >= long_press_duration:
				pick_up_item(item)
				pointer.modulate = Color(1, 1, 1, 1)
				
		InteractionState.HOLDING:
			## 如果当前没有抓住物品，则说明目标格子不存在物品，可以直接回退到IDLE状态
			if button_container:
				button_container = null
			if not current_held_item:
				interaction_state = InteractionState.IDLE
				pointer.hide()
				return
			
			# 物品跟随鼠标
			current_held_item.global_position = pointer.global_position - current_held_item.size / 2
			
			# 显示放置区域预览
			pointer.show()
			drop_item_vision()
			
			# 如果在此时按下按键，可以旋转物品
			if Input.is_key_pressed(KEY_8):
				rotate_held_item()
				# 旋转后立即更新预览以反映新的尺寸
				drop_item_vision()
	
	# 松开鼠标放下物品
	if interaction_state == InteractionState.HOLDING and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		clear_preview()  # 清除预览效果
		drop_item()
		press_time = 0

## 选择物品
## 点击物品时，在指定位置生成按钮容器菜单，传入玩家状态信息。
## [param item]: 被选中的物品，类型为 [DragableItem]
## [param at_position]: 菜单显示位置，类型为 [Vector2]
func _select_item(item: DragableItem, at_position: Vector2):
	# 清理之前的button_container
	button_container = null
	
	button_container = button_container_popum.instantiate() as ButtonContainer
	button_container_control.add_child(button_container)
	button_container._generate(ButtonContainer.get_button_info_from(item.binding_item.get_func_callable(), [binding_status]), at_position)
	
	# 重置按压时间，但保持当前交互状态
	press_time = 0.0

## 检查鼠标是否在按钮容器区域内
## 判断鼠标是否位于按钮容器的显示区域内。
## [br][br][b]返回:[/b] [bool] 如果鼠标在按钮容器区域内则返回true
func _is_mouse_over_button_container() -> bool:
	if not button_container or not is_instance_valid(button_container) or not button_container.visible:
		return false
	
	var mouse_pos = get_global_mouse_position()
	var button_rect = button_container.get_global_rect()
	return button_rect.has_point(mouse_pos)
	
#endregion

#region 输入处理

## 处理未处理的输入事件
## 处理系统级的输入事件，主要用于调试功能。
## [param event]: 输入事件，类型为 [InputEvent]
func _unhandled_input(event: InputEvent) -> void:
	# if event is InputEventKey:
	# 	if event.keycode == KEY_9 and event.is_pressed():
	# 		print("背包物品状态:")
	# 		for item in items_in_inventory:
	# 			print("物品%s的起始存放位置%s" % [item.binding_item.item_name, item.current_slot.current_index])
	pass

#endregion
