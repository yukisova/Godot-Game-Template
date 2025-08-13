## @editing: Sora [br]
## @describe: 状态基类 - 定义状态机状态的抽象接口
## 
## 该抽象类为所有状态机状态提供统一的生命周期接口。
## 状态可以是简单的行为状态，也可以是复杂的状态机组合。
## 
## 状态生命周期：
## 1. _enter(): 进入状态时执行
## 2. _update(): 状态活跃时每帧执行
## 3. _fixed_update(): 状态活跃时每物理帧执行
## 4. _blur_update(): 状态非活跃但仍在栈中时执行
## 5. _exit(): 离开状态时执行
## 
## 状态控制：
## - _pause(): 暂停状态更新
## - _continue(): 恢复状态更新
## 
## 功能特性：
## - 标准生命周期管理
## - 暂停/恢复机制
## - 模糊更新支持
## - 可扩展的状态行为
@abstract class_name IState
extends Node

## 进入状态
## 当状态被激活时调用，用于初始化状态相关的数据和设置
func _enter():
	pass

## 状态更新
## 状态活跃时每帧调用，处理状态的主要逻辑
## @param _delta: 帧时间间隔
func _update(_delta: float) -> void:
	pass

## 物理更新
## 状态活跃时每个物理帧调用，处理物理相关的状态逻辑
## @param _delta: 物理帧时间间隔
func _fixed_update(_delta: float) -> void:
	pass

## 离开状态
## 当状态被停用时调用，用于清理状态相关的数据和设置
func _exit():
	pass

## 模糊更新
## 当状态不是当前活跃状态但仍在状态栈中时调用
## 用于处理后台状态的必要更新
## @param _delta: 帧时间间隔
func _blur_update(_delta: float):
	pass

## 暂停状态
## 暂停状态的更新，通常在游戏暂停时调用
func _pause():
	pass

## 继续状态
## 恢复状态的更新，通常在游戏恢复时调用
func _continue():
	pass
