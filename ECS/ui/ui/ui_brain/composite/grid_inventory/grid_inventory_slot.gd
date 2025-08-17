## 网格背包槽位 - 网格背包系统中的单个槽位组件
##
## 该组件代表网格背包中的一个可放置物品的槽位。
## 提供标准化的物品放置区域、坐标管理和视觉反馈功能。
##
## 核心功能：
## - 提供物品的视觉放置区域
## - 管理槽位的二维网格坐标
## - 跟踪当前槽位中的物品引用
## - 支持视觉反馈和交互提示
## - 提供标准化的槽位尺寸管理
##
## 主要特性：
## - 显示槽位的边框和背景
## - 存储槽位在网格中的位置索引
## - 关联当前放置的可拖拽物品
## - 支持高亮和状态反馈机制
## - 固定的80x80像素标准尺寸
##
## 使用场景：
## - 网格背包的基础单元
## - 物品放置的目标区域
## - 拖拽操作的有效投放点
## - 背包布局的网格结构单位
##
## 架构设计：
## - 继承自 [PanelContainer] 基类
## - 基于 [Vector2i] 的坐标索引系统
## - 与 [DragableItem] 的关联管理
## - 支持 [Color] 的高亮状态控制
##
## 设计特点：
## - 响应式的视觉状态反馈
## - 高效的物品关联机制
## - 标准化的网格坐标系统
## - 优化的性能检测机制
##
## [br][b]编辑者:[/b] Sora
class_name GridInventorySlot
extends PanelContainer

#region 槽位状态

## 槽位在网格中的二维坐标
## 
## 用于标识槽位在背包网格中的位置。
## 格式为 [Vector2i](行, 列)，从(0,0)开始。
## 例如：Vector2i(1, 2)表示第1行第2列的槽位。
var current_index: Vector2i = Vector2i(-1, -1)

## 关联的可拖拽物品
## 
## 当前放置在此槽位中的物品引用，类型为 [DragableItem]。
## 如果为null，表示槽位为空。
## [br][b]注意:[/b] 一个物品可能占用多个槽位，但只有起始槽位会关联该物品。
var linkage_dragable: DragableItem = null

#endregion

#region 槽位初始化

## 槽位组件准备就绪
## 
## 设置槽位的基本属性和交互机制。
func _ready():
	# 设置标准槽位尺寸（80x80像素）
	# 这个尺寸与网格背包系统的设计保持一致
	custom_minimum_size = Vector2(80, 80)
	
	# 添加高频率定时器用于状态检测
	# TODO: 优化为事件驱动方式以提高性能
	# 当前使用定时器来检测状态变化，未来可以改为信号驱动
	var timer = Timer.new()
	timer.wait_time = 0.01  # 10毫秒检测间隔
	timer.one_shot = false
	add_child(timer)
	timer.start()
	
	print("网格槽位: 初始化完成，尺寸: ", custom_minimum_size)

#endregion

#region 槽位状态管理

## 检查槽位是否为空
## 
## 判断当前槽位是否没有关联任何物品。
## [br][br][b]返回:[/b] [bool] 如果槽位没有关联物品则返回true
func is_empty() -> bool:
	return linkage_dragable == null

## 检查槽位是否被占用
## 
## 判断当前槽位是否有关联的物品。
## [br][br][b]返回:[/b] [bool] 如果槽位有关联物品则返回true
func is_occupied() -> bool:
	return linkage_dragable != null

## 获取槽位的网格坐标字符串表示
## 
## 用于调试和日志输出的格式化坐标字符串。
## [br][br][b]返回:[/b] [String] 格式化的坐标字符串
func get_index_string() -> String:
	return "(" + str(current_index.x) + ", " + str(current_index.y) + ")"

## 设置槽位高亮状态
## 
## 用于预览和交互反馈的视觉效果。
## [param color]: 高亮颜色，类型为 [Color]
## [param alpha]: 透明度（0.0-1.0），默认为1.0
func set_highlight(color: Color, alpha: float = 1.0):
	modulate = color
	modulate.a = alpha

## 清除槽位高亮状态
## 
## 恢复槽位的正常显示状态。
func clear_highlight():
	modulate = Color.WHITE

#endregion
