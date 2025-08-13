## @editing: Sora [br]
## @describe: 可拖拽物品 - 网格背包系统中的物品显示组件
##
## 该组件表示背包系统中的单个物品，提供：
## - 物品的可视化显示
## - 拖拽操作的数据绑定
## - 网格位置的状态管理
## - 物品旋转和变换支持
##
## 主要功能：
## - 自动绑定物品数据和纹理
## - 根据物品尺寸调整显示大小
## - 跟踪当前和原始槽位位置
## - 支持物品的旋转状态
## - 响应式的大小和位置更新
##
## 使用场景：
## - 网格背包的物品表示
## - 拖拽系统的可视化元素
## - 物品管理界面的基础组件
## - 物品交互的用户界面
##
## 设计特点：
## - 响应式大小调整
## - 数据驱动的显示更新
## - 灵活的槽位绑定机制
## - 自动的纹理和尺寸同步
class_name DragableItem
extends TextureRect

#region 物品数据绑定

## 绑定的物品数据
## 当设置时自动更新纹理和尺寸信息
## 包含物品的所有属性：名称、描述、纹理、尺寸、重量等
var binding_item: Item:
	set(v):
		binding_item = v
		if binding_item:
			# 自动更新纹理显示
			texture = binding_item.item_texture
			# 更新物品尺寸
			item_size = binding_item.item_tilesize
			# 重新计算显示尺寸
			_update_display_size()

#endregion

#region 物品状态属性

## 物品在网格中的尺寸
## 决定物品占用的网格数量，格式为Vector2i(宽度, 高度)
## 例如：Vector2i(2, 1)表示物品占用2列1行的网格空间
var item_size: Vector2i = Vector2i(1, 1)

## 当前所在的网格槽位
## 表示物品在背包中的当前位置
## 当物品被拖拽时，此值可能为null
var current_slot: GridInventorySlot = null

## 原始槽位位置
## 用于拖拽失败时的回退位置
## 在开始拖拽前保存的原始位置
var origin_slot: GridInventorySlot = null

## 物品是否已旋转
## 标记物品的旋转状态
## 影响物品的显示方向和占用网格的计算
var is_rotated: bool = false

#endregion

#region 组件初始化

## 组件准备就绪
## 设置初始显示状态和交互模式
func _ready():
	# 根据物品尺寸更新显示大小
	_update_display_size()
	# 禁用鼠标交互，由父级容器统一管理
	# 这样可以避免鼠标事件冲突，确保拖拽逻辑的一致性
	mouse_filter = Control.MOUSE_FILTER_IGNORE

## 更新显示尺寸
## 根据物品的网格尺寸调整UI组件大小
## 每个网格单元对应80x80像素的显示空间
func _update_display_size():
	# 每个网格单元为80x80像素
	# 根据物品的网格尺寸计算实际显示尺寸
	custom_minimum_size = Vector2(80, 80) * Vector2(item_size)
	size = custom_minimum_size

#endregion

#region 物品状态管理

## 获取物品的网格价值
## 用于排序和优先级计算
## @return: 物品占用的网格面积
func get_grid_value() -> int:
	return item_size.x * item_size.y

## 检查物品是否可以旋转
## 某些物品可能不支持旋转（如1x1的物品）
## @return: 是否可以旋转
func can_rotate() -> bool:
	# 1x1的物品旋转没有意义
	return item_size.x != item_size.y

## 旋转物品
## 交换物品的宽度和高度
## 注意：这需要配合网格背包系统的旋转逻辑使用
func rotate_item():
	if not can_rotate():
		return
	
	# 交换宽度和高度
	item_size = Vector2i(item_size.y, item_size.x)
	is_rotated = !is_rotated
	
	# 更新显示尺寸
	_update_display_size()

## 重置物品旋转状态
## 将物品恢复到未旋转状态
func reset_rotation():
	if is_rotated:
		item_size = Vector2i(item_size.y, item_size.x)
		is_rotated = false
		_update_display_size()

#endregion
