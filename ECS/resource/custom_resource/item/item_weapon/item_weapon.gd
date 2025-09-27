## 武器物品类 - 可装备武器的数据和行为定义
## 该类定义了游戏中所有武器物品的基础结构和功能，武器物品包含攻击逻辑、装备管理、击中效果等核心功能
## 每个武器都有对应的攻击节点，提供具体的攻击行为实现
## 核心功能：武器系统、攻击逻辑、状态管理、事件通知、击中效果
## 武器工作流程：玩家选择装备→调用_equip方法→获取装备系统组件→发出攻击节点变化信号→装备系统处理挂载
## 目前的想法是，打开仓库的时候，如果玩家装备了武器的话会额外加载武器UI节点，武器攻击节点是分离的，武器装备UI用于显示武器装备信息，武器攻击节点用于显示武器攻击信息
## 架构设计：继承自 [Item] 基类，集成 [PackedScene] 的攻击节点系统
## [br][b]编辑者:[/b] Sora
class_name ItemWeapon
extends Item

## 武器攻击节点场景
## 定义武器攻击行为的节点场景，装备时会被实例化并挂载到装备系统下
@export var weapon_node: PackedScene
## 武器装备UI
## 武器装备时的UI，用于显示武器装备信息
@export var equipment_control: PackedScene

## 击中效果列表
## 武器造成伤害时的各种击中效果，类型为 [Array] of [IHitEffect]
@export var hit_effect_list: Array[IHitEffect]

## 装备状态标志
## 指示该武器当前是否已被装备
var is_equipped: bool

## FIXME: 装备/卸下
## 根据武器装备状态返回不同的功能选项（装备/卸下）
## [br][br][b]返回:[/b] [Array] of [Dictionary] 包含功能信息的字典数组
func get_func_callable() -> Array[Dictionary]:
	var result = {}
	
	# 根据装备状态添加相应的功能选项
	if not is_equipped:
		# 未装备时显示"装备"选项
		result.push_front({
			STR_NAME:"equip",
			STR_FUNC:func(_context: Dictionary):
				pass,
			STR_TEXT:"装备"
		})
	else:
		# 已装备时显示"卸下"选项
		result.push_front({
			STR_NAME:"unequip",
			STR_FUNC:func(_context: Dictionary):
				pass,
			STR_TEXT:"卸下"
		})
	
	return result
