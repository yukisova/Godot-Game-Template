## 移动策略基类 - 定义实体移动行为的抽象接口
## 该抽象类为所有移动策略提供统一的接口和基础功能，移动策略采用策略模式设计
## 允许在运行时动态切换不同的移动行为，如玩家控制、AI巡逻、直线飞行等
## 策略类型：VectorMove（向量移动）、StraightMove（直线飞行）、PathMove（路径跟随）
## 功能特性：实体绑定机制、黑板数据共享、存档系统支持、可扩展的策略类型
## [br][b]编辑者:[/b] Sora
@abstract class_name IUpdateAction
extends IAction

## 移动策略类型枚举
## 用于标识和切换不同的移动策略实现
enum MoveStrategyType {
	VectorMove = 0  ## 向量移动策略
}

## 绑定的实体
## 由移动组件传入，策略将作用于此实体
var binding_entity: IEntity

## 行为状态列表
## IUpdateAction的子类应当实现该列表，用于标识行为
var action_states: Array[StringName]

## 黑板节点
## 用于策略间数据共享，如移动方向、目标位置等信息
@export var blackboard: ContainerBlackboard

## 验证策略的适用性并进行必要的初始化设置
@abstract func _initialize()

@abstract func _update(_delta: float)

func _reset():
	pass

func _detect_state():
	pass
