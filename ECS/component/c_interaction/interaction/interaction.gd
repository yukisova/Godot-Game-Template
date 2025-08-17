## 交互逻辑基类 - 定义交互逻辑的抽象接口
##
## 该抽象类为所有交互提供统一的框架。交互可以是主动的（需要玩家确认）
## 或被动的（自动触发），如自动收集物品、触发陷阱、进入区域等。
##
## 交互类型：
## - 自动收集：进入范围自动收集物品
## - 触发陷阱：接触后立即触发的陷阱
## - 区域传送：进入后自动传送到其他场景
## - 状态改变：接触后改变实体状态
## - 对话触发：接近NPC后自动开始对话
## - 主动交互：需要玩家按键确认的交互
##
## 功能特性：
## - 实体绑定机制
## - 激活/取消激活事件系统
## - 自动信号连接
## - 可扩展的交互逻辑
##
## 架构设计：
## - 抽象基类，继承自 [Node]
## - 与 [IEntity] 的绑定机制
## - 基于信号的事件驱动架构
## - 支持自动生命周期管理
##
## [br][b]编辑者:[/b] Sora
@abstract class_name Interaction
extends Node

## 绑定的实体
## 
## 拥有此交互逻辑的实体实例，类型为 [IEntity]。
var binding_entity: IEntity

## 交互激活信号
## 
## 当交互条件满足时触发，传递触发交互的目标实体。
## [param target_entity]: 触发交互的目标实体，类型为 [IEntity]
signal interact_activated(target_entity: IEntity)

## 交互取消激活信号
## 
## 当交互条件不再满足时触发，用于清理或回滚操作。
signal interact_deactivated

## 节点进入场景树时的初始化
## 自动连接交互信号到对应的处理方法
func _enter_tree() -> void:
	# 避免重复连接信号
	if not interact_activated.is_connected(_on_interact_activated):
		interact_activated.connect(_on_interact_activated)
	if not interact_deactivated.is_connected(_on_interact_deactivated):
		interact_deactivated.connect(_on_interact_deactivated)

## 交互激活处理（抽象方法）
## 
## 当交互被激活时的具体逻辑实现，子类需要重写此方法。
## [param target_entity]: 触发交互的目标实体（通常是玩家），类型为 [IEntity]
@abstract func _on_interact_activated(target_entity: IEntity)

## 交互取消激活处理（抽象方法）
## 
## 当交互被取消时的清理逻辑实现，子类需要重写此方法。
@abstract func _on_interact_deactivated()
