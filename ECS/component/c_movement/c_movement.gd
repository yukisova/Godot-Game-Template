## 移动组件 - 为实体提供移动能力和移动策略管理
##
## 该组件基于策略模式设计，通过配置不同的移动策略来实现各种移动行为。
## 支持向量移动、轨迹飞行、路径跟随等多种移动方式。
##
## 移动策略类型：
## - 向量移动：基于输入向量的实时移动
## - 轨迹移动：沿预定义路径的移动
## - 物理移动：基于物理引擎的移动
## - AI移动：基于AI算法的智能移动
##
## 功能特性：
## - 策略模式设计，易于扩展新的移动方式
## - 与输入系统无缝集成
## - 支持平滑过渡和插值
## - 可配置的移动参数
##
## [br][b]编辑者:[/b] Sora
@tool
class_name CMovement
extends IComponent

## 移动策略
## 
## 定义实体的具体移动行为逻辑，支持多种移动方式。
## 详见 [MoveStrategy] 基类和具体的策略实现。
@export var move_strategy: MoveStrategy

func _enter_tree() -> void:
	component_name = ComponentName.C_MOVEMENT

## 组件初始化
## 
## 设置移动策略的绑定实体并执行策略初始化。
## [param _owner]: 拥有此组件的实体，必须是 [IEntity] 类型
## [param _load_data]: 可选的加载数据，用于恢复保存的状态
func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)

	# 绑定实体到移动策略，建立策略与实体的关联
	move_strategy.binding_entity = component_owner
	# 执行策略的检查和初始化，确保策略可以正常工作
	move_strategy._check_and_init()
	
	initialize_complete.emit()

## 移动逻辑更新
## 
## 每帧调用移动策略的更新方法来执行移动逻辑。
## [param _delta]: 帧时间间隔，用于平滑的移动计算
func _update(_delta: float):
	move_strategy._update(_delta)

func _reset():
	move_strategy._reset()

#region 存档系统
## 保存移动组件数据
## 
## 收集移动组件的当前状态用于存档。
## [br][br][b]返回:[/b] [Dictionary] 包含移动组件存档数据的字典
func _save_as() -> Dictionary:
	# TODO: 实现移动状态的存档逻辑
	return {}

## 加载移动组件数据
## 
## 从存档数据中恢复移动组件的状态。
## [param _data]: 包含移动组件存档数据的字典
func _load_by(_data: Dictionary):
	# TODO: 实现移动状态的读档逻辑
	pass
#endregion
