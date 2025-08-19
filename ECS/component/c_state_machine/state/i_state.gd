## 状态基类 - 定义状态机状态的抽象接口
## 为所有状态机状态提供统一的生命周期接口
## 状态生命周期：enter进入、update更新、fixed_update物理更新、blur_update模糊更新、exit离开
## 状态控制：pause暂停、continue恢复，支持分层状态机的模糊更新
## [br][b]编辑者:[/b] Sora
@abstract class_name IState
extends Node

## 进入状态，当状态被激活时调用，用于初始化状态相关的数据和设置
func _enter():
	pass

## 状态更新，状态活跃时每帧调用，处理状态的主要逻辑
## [param _delta]: 帧时间间隔
func _update(_delta: float) -> void:
	pass

## 物理更新，状态活跃时每个物理帧调用，处理物理相关的状态逻辑
## [param _delta]: 物理帧时间间隔
func _fixed_update(_delta: float) -> void:
	pass

## 离开状态，当状态被停用时调用，用于清理状态相关的数据和设置
func _exit():
	pass

## 模糊更新，当状态不是当前活跃状态但仍在状态栈中时调用
## [param _delta]: 帧时间间隔
func _blur_update(_delta: float):
	pass

## 暂停状态，暂停状态的更新，通常在游戏暂停时调用
func _pause():
	pass

## 继续状态，恢复状态的更新，通常在游戏恢复时调用
func _continue():
	pass
