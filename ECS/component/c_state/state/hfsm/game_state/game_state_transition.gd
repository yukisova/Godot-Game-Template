## @editing: Sora [br]
## @describe: 游戏的过渡状态，该状态下 [br]
##			1. MapData正在加载环境，需要时间，期间应当按照指定次序加载内容 [br]
##			退出条件： [br]
##			1. MapData加载完毕，并发送了相关的信号 [br]
@tool
class_name GameStartTransition
extends StateHfsm

var update_trigger = false

func _enter():
	Main.entity_initialzable = false

func _update(_delta: float) -> void:
	if update_trigger:
		state_transition.emit(get_transition_state())

func _exit():
	update_trigger = false
	Main.entity_initialzable = true
