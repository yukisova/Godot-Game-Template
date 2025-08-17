## 移动策略基类 - 定义实体移动行为的抽象接口
##
## [br][b]编辑者:[/b] Sora
## 
## 该抽象类为所有移动策略提供统一的接口和基础功能。移动策略采用策略模式设计，
## 允许在运行时动态切换不同的移动行为，如玩家控制、AI巡逻、直线飞行等。
## 
## 策略类型：
## - VectorMove：基于向量的移动策略（玩家输入或AI控制）
## - StraightMove：直线飞行策略（子弹、飞行道具等）
## - PathMove：路径跟随策略（预定义轨迹）
## - PhysicsMove：物理驱动策略（重力、推力等）
## 
## 功能特性：
## - 实体绑定机制
## - 黑板数据共享
## - 存档系统支持
## - 可扩展的策略类型
@abstract class_name IUpdateAction
extends IAction

## 移动策略类型枚举
## 用于标识和切换不同的移动策略实现
enum MoveStrategyType {
	VectorMove = 0  ## 向量移动策略
}

## 绑定的实体
## 由移动组件传入，策略将作用于此实体（支持所有IEntity的子类）
var binding_entity: IEntity

## 行为状态列表
## 
## IUpdateAction的子类应当实现该列表，用于标识行为，比如["on_floor", "on_wall", "on_ceiling"]
var action_states: Array[StringName]

## 黑板节点
## 用于策略间数据共享，如移动方向、目标位置等信息
@export var blackboard: ContainerBlackboard

## 策略初始化
## 验证策略的适用性并进行必要的初始化设置
## 子类应该在此方法中设置action_states并初始化current_action_state
@abstract func _initialize()

@abstract func _update(_delta: float)

func _reset():
	pass

func _detect_state():
	pass
