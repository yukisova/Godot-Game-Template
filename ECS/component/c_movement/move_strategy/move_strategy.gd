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
@abstract class_name MoveStrategy
extends Node

## 移动策略类型枚举
## 用于标识和切换不同的移动策略实现
enum MoveStrategyType {
	VectorMove = 0  ## 向量移动策略
}

## 绑定的实体
## 由移动组件传入，策略将作用于此实体（支持所有IEntity的子类）
var binding_entity: IEntity

## 黑板节点
## 用于策略间数据共享，如移动方向、目标位置等信息
@export var blackboard: ContainerBlackboard

## 检查和初始化
## 验证策略的适用性并进行必要的初始化设置
@abstract func _check_and_init()

func _reset():
	pass

## 更新移动逻辑
## 每帧调用的核心移动逻辑实现
## @param _delta: 帧时间间隔
@abstract func _update(_delta: float)

## 保存策略数据
## 将策略的当前状态保存为字典格式
## @return: 包含策略状态的字典
@abstract func _save_as() -> Dictionary
