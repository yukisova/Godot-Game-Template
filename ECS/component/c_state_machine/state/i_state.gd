## 状态基类 - 定义状态机状态的抽象接口
## 为所有状态机状态提供统一的生命周期接口
## 状态生命周期：enter进入、update更新、fixed_update物理更新、blur_update模糊更新、exit离开
## 状态控制：pause暂停、continue恢复，支持分层状态机的模糊更新
## [br][b]编辑者:[/b] Sora
@abstract class_name IState
extends Node

@abstract func _enter()
@abstract func _update(_delta: float)
@abstract func _fixed_update(_delta: float)
@abstract func _exit()
@abstract func _blur_update(_delta: float)
@abstract func _pause()
@abstract func _continue()
