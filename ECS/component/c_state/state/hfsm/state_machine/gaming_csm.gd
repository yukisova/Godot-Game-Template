## @editing: Sora
## @describe: 游戏进行时子状态机
##			  其下有四个状态
##			  1. 正常游戏: 允许玩家操控自己的角色，进行游戏场景内的互动
##			  2. 游戏暂停: 游戏冻结，只允许UI继续运行

@tool
class_name GamingChildStateMachine
extends StateMachineHfsm

var update_trigger = false

func _setup() -> void:
	super()
	

func _enter():
	super()
	SSubSystemManager.sub_systems_setup_start.emit()

func _update(_delta: float) -> void:
	super._update(_delta)
	if update_trigger:
		state_transition.emit(get_transition_state())

func _exit():
	super()
	SSignalBus.ui_main_returned.emit()
	update_trigger = false
