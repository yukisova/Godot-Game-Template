## 装备物品类 - 可穿戴装备的基础实现
##
## 该类是所有可装备物品的基类，提供装备和卸下的核心功能。
## 装备物品包括护甲、饰品、工具等非武器类的可穿戴装备。
##
## 核心功能：
## - 装备系统：提供装备和卸下的标准接口
## - 状态管理：跟踪装备的穿戴状态
## - 节点集成：支持装备节点的动态加载和管理
## - 事件通知：通过信号系统通知装备状态变化
##
## 装备工作流程：
## 1. 玩家选择装备物品
## 2. 调用 [method _equip] 方法
## 3. 获取玩家的装备系统组件
## 4. 发出装备变化信号
## 5. 装备系统处理节点挂载和状态更新
##
## 应用场景：
## - 防护装备：头盔、护甲、靴子等防护用品
## - 功能装备：工具、配件等功能性装备
## - 饰品装备：戒指、项链等属性增强装备
## - 特殊装备：魔法物品、科技装备等
##
## 使用示例：
## [codeblock]
## var helmet = ItemEquipment.new()
## helmet.item_name = "钢铁头盔"
## helmet.equipment_node = preload("res://equipment/helmet_node.tscn")
## [/codeblock]
##
## 架构设计：
## - 继承自 [Item] 基类
## - 集成 [PackedScene] 的装备节点系统
## - 与 [EquipmentExtension] 的装备系统集成
## - 支持动态的节点挂载和卸载
##
## [br][b]编辑者:[/b] Sora
class_name ItemEquipment
extends Item

## 装备节点场景
## 
## 装备时实例化的节点场景，用于提供装备的功能实现。
## 该节点会被挂载到玩家的装备系统组件下，类型为 [PackedScene]。
@export var equipment_node: PackedScene

## 装备状态标志
## 
## 指示该装备当前是否已被穿戴。
var is_equipped: bool

## 装备物品
## 
## 当玩家选择装备该物品时调用此方法。
## [param args]: 参数数组，第一个参数应为 [CStatus] 组件
func _equip(...args):
	var c_status = args[0] as CStatus
	var equipment: EquipmentExtension = c_status.status_extension[StatusExtension.ExtensionType.EQUIPMENT]
	# 发出装备节点变化信号，通知装备系统处理装备逻辑
	equipment.equipment_node_changed.emit(self)

## 卸下装备
## 
## 当玩家选择卸下该装备时调用此方法。
## [param args]: 参数数组，第一个参数应为 [CStatus] 组件
func _unequip(...args):
	var c_status = args[0] as CStatus
	var equipment: EquipmentExtension = c_status.status_extension[StatusExtension.ExtensionType.EQUIPMENT]
	# 发出装备移除信号，传递 null 表示移除装备
	equipment.equipment_node_changed.emit(null)

## 获取可调用功能列表（重写方法）
## 
## 根据装备状态返回不同的功能选项（装备/卸下）。
## [br][br][b]返回:[/b] [Array] of [Dictionary] 包含功能信息的字典数组
func get_func_callable() -> Array[Dictionary]:
	var result = super()
	
	# 根据装备状态添加相应的功能选项
	if not is_equipped:
		# 未装备时显示"装备"选项
		result.push_front({
			STR_NAME:"equip",
			STR_FUNC:_equip,
			STR_TEXT:"装备"
		})
	else:
		# 已装备时显示"卸下"选项
		result.push_front({
			STR_NAME:"unequip",
			STR_FUNC:_unequip,
			STR_TEXT:"卸下"
		})
	
	return result
