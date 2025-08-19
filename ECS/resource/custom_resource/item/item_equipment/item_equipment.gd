## 装备物品类 - 可穿戴装备的基础实现
## 该类是所有可装备物品的基类，提供装备和卸下的核心功能
## 装备物品包括护甲、饰品、工具等非武器类的可穿戴装备
## 核心功能：装备系统、状态管理、节点集成、事件通知
## 装备工作流程：玩家选择装备→调用_equip方法→获取装备系统组件→发出装备变化信号→处理节点挂载
## 应用场景：防护装备、功能装备、饰品装备、特殊装备
## 架构设计：继承自 [Item] 基类，集成 [PackedScene] 的装备节点系统
## [br][b]编辑者:[/b] Sora
class_name ItemEquipment
extends Item

## 装备节点场景
## 装备时实例化的节点场景，用于提供装备的功能实现
@export var equipment_node: PackedScene

## 装备状态标志
## 指示该装备当前是否已被穿戴
var is_equipped: bool

## 当玩家选择装备该物品时调用此方法
## [param args]: 参数数组，第一个参数应为 [CStatusList] 组件
func _equip(...args):
	var c_status = args[0] as CStatusList
	var equipment: EquipmentExtension = c_status.status_extension[StatusExtension.ExtensionType.EQUIPMENT]
	# 发出装备节点变化信号，通知装备系统处理装备逻辑
	equipment.equipment_node_changed.emit(self)

## 当玩家选择卸下该装备时调用此方法
## [param args]: 参数数组，第一个参数应为 [CStatusList] 组件
func _unequip(...args):
	var c_status = args[0] as CStatusList
	var equipment: EquipmentExtension = c_status.status_extension[StatusExtension.ExtensionType.EQUIPMENT]
	# 发出装备移除信号，传递 null 表示移除装备
	equipment.equipment_node_changed.emit(null)

## 根据装备状态返回不同的功能选项（装备/卸下）
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
