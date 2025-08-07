## @editing: Sora [br]
## @describe: 游戏的过渡状态，该状态下 [br]
##			1. MapData正在加载环境，需要时间，期间应当按照指定次序加载内容 [br]
##			退出条件： [br]
##			1. MapData加载完毕，并发送了相关的信号 [br]
## FIXME 游戏过渡加载状态外与游戏运行中加载状态应当区别开来，这个状态只能用作在主菜单加载游戏的过渡状态
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
	
	SSignalBus.game_loop_start.emit()
