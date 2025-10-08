## 交互逻辑基类 - 定义交互逻辑的抽象接口
## 该抽象类为所有交互提供统一的框架。交互可以是主动的（需要玩家确认）或被动的（自动触发）
## 交互类型：自动收集、触发陷阱、区域传送、状态改变、对话触发、主动交互
## 功能特性：实体绑定机制、激活/取消激活事件系统、自动信号连接、可扩展的交互逻辑
## 架构设计：抽象基类，继承自Node，与IEntity的绑定机制，基于信号的事件驱动架构
## [br][b]编辑者:[/b] Sora
@abstract class_name IInteraction
extends Node
## 绑定的实体
## 拥有此交互逻辑的实体实例
var binding_entity: IEntity

## 交互激活信号
## 当交互条件满足时触发，传递触发交互的目标实体
signal interact_activated(target_entity: IEntity)

## 交互完成信号
## 当交互完成时触发
signal interact_finished()

## 交互取消激活信号
## 当交互条件不再满足时触发，用于清理或回滚操作
signal interact_deactivated

## 节点进入场景树时的初始化—自动连接交互信号到对应的处理方法
func _enter_tree() -> void:
	# 避免重复连接信号
	if not interact_activated.is_connected(_on_interact_activated):
		interact_activated.connect(_on_interact_activated)
	if not interact_deactivated.is_connected(_on_interact_deactivated):
		interact_deactivated.connect(_on_interact_deactivated)

## 交互激活处理—当交互被激活时的具体逻辑实现，子类需要重写此方法
## [param target_entity]: 触发交互的目标实体（通常是玩家）
@abstract func __interact_begin(target_entity: IEntity) -> bool

## 交互重置处理—当交互被重置时的具体逻辑实现，子类需要重写此方法
@abstract func __interact_reset() -> void

func _on_interact_activated(_target_entity: IEntity) -> void:
	if await __interact_begin(_target_entity):
		interact_finished.emit()

## 交互取消激活处理—当交互被取消时的清理逻辑实现，子类需要重写此方法
func _on_interact_deactivated() -> void:
	__interact_reset()
