## 武器物品类 - 可装备武器的数据和行为定义
##
## 该类定义了游戏中所有武器物品的基础结构和功能。
## 武器物品包含攻击逻辑、装备管理、击中效果等核心功能，
## 每个武器都有对应的攻击节点，提供具体的攻击行为实现。
##
## 核心功能：
## - 武器系统：提供武器装备和卸下的标准接口
## - 攻击逻辑：通过攻击节点实现具体的攻击行为
## - 状态管理：跟踪武器的装备状态
## - 事件通知：通过信号系统通知武器状态变化
## - 击中效果：支持多种击中效果的配置
##
## 武器工作流程：
## 1. 玩家选择装备武器
## 2. 调用 [method _equip] 方法
## 3. 获取玩家的装备系统组件
## 4. 发出攻击节点变化信号
## 5. 装备系统处理武器节点挂载
## 6. 武器成为可用状态
##
## 攻击节点系统：
## - 每个武器包含一个 [member weapon_node]（攻击节点场景）
## - 攻击节点定义了武器的具体攻击行为
## - 支持不同类型的攻击模式（近战、远程、魔法等）
## - 可配置攻击参数（伤害、射程、冷却等）
##
## 应用场景：
## - 近战武器：剑、刀、锤等近距离攻击武器
## - 远程武器：弓箭、枪械、投掷武器等
## - 魔法武器：法杖、魔法书等施法工具
## - 特殊武器：科技武器、特殊能力武器等
##
## 使用示例：
## [codeblock]
## var pistol = ItemWeapon.new()
## pistol.item_name = "手枪"
## pistol.weapon_node = preload("res://weapons/pistol_attack_node.tscn")
## [/codeblock]
##
## 架构设计：
## - 继承自 [Item] 基类
## - 集成 [PackedScene] 的攻击节点系统
## - 基于 [Array] of [IHitEffect] 的击中效果管理
## - 与 [EquipmentExtension] 的装备系统集成
##
## [br][b]编辑者:[/b] Sora
class_name ItemWeapon
extends Item

## 武器攻击节点场景
## 
## 定义武器攻击行为的节点场景，装备时会被实例化并挂载到装备系统下。
## 该节点包含武器的所有攻击逻辑、参数配置和特效处理，类型为 [PackedScene]。
@export var weapon_node: PackedScene

## 击中效果列表
## 
## 武器造成伤害时的各种击中效果，类型为 [Array] of [IHitEffect]。
@export var hit_effect_list: Array[IHitEffect]

## 装备状态标志
## 
## 指示该武器当前是否已被装备。
var is_equipped: bool

## 装备武器
## 
## 当玩家选择装备该武器时调用此方法。
## [param args]: 参数数组，第一个参数应为 [CStatus] 组件
func _equip(...args):
	var c_status = args[0] as CStatus
	var equipment: EquipmentExtension = c_status.status_extension[StatusExtension.ExtensionType.EQUIPMENT]
	# 发出攻击节点变化信号，通知装备系统处理武器装备逻辑
	equipment.attack_node_changed.emit(self)

## 卸下武器
## 
## 当玩家选择卸下该武器时调用此方法。
## [param args]: 参数数组，第一个参数应为 [CStatus] 组件
func _unequip(...args):
	var c_status = args[0] as CStatus
	var equipment: EquipmentExtension = c_status.status_extension[StatusExtension.ExtensionType.EQUIPMENT]
	# 发出武器移除信号，传递 null 表示移除当前武器
	equipment.attack_node_changed.emit(null)

## 获取可调用功能列表（重写方法）
## 
## 根据武器装备状态返回不同的功能选项（装备/卸下）。
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
