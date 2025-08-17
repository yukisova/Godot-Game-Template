## 玩家属性HUD - 显示角色基础信息和快捷操作界面
##
## 该HUD集成了多个玩家相关的UI元素：
## - 时间循环系统的时钟显示
## - 背包抽屉式快捷栏
## - 物品拖拽和交互功能
## - 玩家状态的实时更新
##
## 主要功能：
## - 实时显示游戏内时间（小时/分钟指针）
## - 提供背包物品的快速访问
## - 支持物品的拖拽操作
## - 动态同步玩家背包变化
##
## UI特性：
## - 抽屉式背包展开/收起动画
## - 可拖拽的物品图标
## - 响应式布局适配
##
## 架构设计：
## - 继承自 [IHud] 基类
## - 与 [FixedEntity] 的玩家实体绑定
## - 集成 [InventoryExtension] 背包系统
## - 使用 [DragableItem] 拖拽组件
##
## [br][b]编辑者:[/b] Sora
extends IHud

#region 实体绑定

## 绑定的实体
## 
## 通常为玩家角色实体，类型为 [FixedEntity]。
var binding_fixed_entity: FixedEntity

#endregion

#region 时间循环UI

@export_group("时间循环", "time_")

## 小时指针
## 
## 用于显示游戏内的小时时间，类型为 [Line2D]。
@export var hour_pointer: Line2D

## 分钟指针  
## 
## 用于显示游戏内的分钟时间，类型为 [Line2D]。
@export var minute_pointer: Line2D

#endregion

#region 背包抽屉UI

@export_group("背包抽屉", "bag_")

## 背包切换按钮
## 
## 控制背包抽屉的展开和收起，类型为 [Button]。
@export var bag_button: Button

## 背包槽位容器
## 
## 存放所有背包槽位的布局容器，类型为 [HBoxContainer]。
@export var bag_slot_container: HBoxContainer

## 背包槽位原型
## 
## 用于动态创建背包槽位的模板，类型为 [PanelContainer]。
@export var bag_slot_prototype: PanelContainer

## 可拖拽物品原型
## 
## 用于创建可拖拽物品图标的模板，类型为 [DragableItem]。
@export var bag_dragable_item_prototype: DragableItem

#endregion

#region 背包系统集成

## 玩家背包扩展
## 
## 引用玩家状态组件中的背包系统，类型为 [InventoryExtension]。
var inventory_in_player: InventoryExtension

#endregion


#region HUD生命周期

## HUD初始化
## 设置时间循环、背包系统和UI交互
func _initialize():
	# 当前暂时禁用，等待系统完善
	print("属性HUD: 初始化已禁用，等待系统完善")
	return
	
	# TODO: 完整的初始化逻辑（已禁用）
	# 以下代码在系统完善后启用：
	# - 连接时间循环系统
	# - 设置背包按钮事件  
	# - 初始化背包槽位
	# - 连接背包变化事件

## HUD刷新
## 更新显示内容（预留接口）
func _refresh():
	pass

#endregion

#region 输入处理

## 处理未处理的输入事件
## 
## [param _event]: 输入事件，类型为 [InputEvent]
func _unhandled_input(_event: InputEvent) -> void:
	# 预留拖拽功能的输入处理
	# TODO: 实现物品拖拽逻辑
	pass

#endregion

#region 时间显示

## 旋转时钟指针
## 
## 根据当前游戏时间更新时钟指针的显示角度。
## [param current_timer]: 当前时间（分钟数）
func rotate_pointer(current_timer: int):
	# 计算小时和分钟的比例
	var hour = current_timer / 60.0 / 24
	var minute = current_timer % 60 / 60.0
	
	# 计算指针旋转角度
	var target_hour_rotation = hour * 2 * PI
	var target_min_rotation = minute * 2 * PI
	
	# 应用旋转
	hour_pointer.rotation = target_hour_rotation
	minute_pointer.rotation = target_min_rotation

#endregion

#region 抽屉式背包动画

## 展开背包抽屉
## 播放滑入动画并禁用按钮防止重复触发
func drawer_on():
	bag_button.button_mask ^= MOUSE_BUTTON_MASK_LEFT  # 临时禁用按钮
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(bag_slot_container, "position", Vector2(0, 16), 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	await tween.finished
	bag_button.button_mask |= MOUSE_BUTTON_MASK_LEFT  # 重新启用按钮

## 收起背包抽屉
## 播放滑出动画并禁用按钮防止重复触发  
func drawer_off():
	bag_button.button_mask ^= MOUSE_BUTTON_MASK_LEFT  # 临时禁用按钮
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(bag_slot_container, "position", Vector2(-bag_slot_container.size.x, 16), 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	await tween.finished
	bag_button.button_mask |= MOUSE_BUTTON_MASK_LEFT  # 重新启用按钮

#endregion

#region 背包事件处理

## 处理背包添加物品事件
## 
## 当背包中添加物品时创建可拖拽的物品图标。
## [param item]: 添加的物品，类型为 [Item]
## [param index]: 物品在背包中的索引
func _on_add_inventory(item: Item, index: int):
	var bag_dragable_item = bag_dragable_item_prototype.duplicate() as DragableItem
	var bag_slot = bag_slot_container.get_child(index)
	
	# 配置可拖拽物品
	bag_slot.add_child(bag_dragable_item)
	bag_dragable_item.binding_item = item
	bag_dragable_item.texture = item.item_texture
	bag_dragable_item.origin_position = bag_slot.global_position
	bag_dragable_item.show()

## 处理背包移除物品事件
## 
## 当背包中移除物品时清理对应的UI元素。
## [param index]: 被移除物品的索引
func _on_remove_inventory(index: int):
	var target_bag_slot = bag_slot_container.get_child(index)
	# 清理槽位中的所有子节点（物品图标）
	target_bag_slot.get_children().map(func(v): return v.queue_free())

#endregion
