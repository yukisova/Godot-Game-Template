## 游戏进行子状态机
## 其下有两个状态
## 1. 正常游戏: 允许玩家操控自己的角色，进行游戏场景内的互动
## 2. 游戏暂停: 游戏冻结，只允许UI继续运行
## @init: 游戏暂停
@tool
class_name GamingChildStateMachine
extends StateMachine

var update_trigger = false

func _update(_delta: float) -> void:
	super._update(_delta)
	if update_trigger:
		state_transition.emit(parent_to_self, "")

func _exit():
	super._exit()
	update_trigger = false
