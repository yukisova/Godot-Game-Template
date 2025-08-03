## @editing: Sora [br]
## @describe: 游戏进行中的暂停状态 [br]
##			1. 除了UI外，游戏帧冻结 [br]
##			退出条件： [br]
##			1. 游戏主场景加载，并发送了相关的信号 [br]
##			2. 游戏退出
@tool
class_name GamingStatePause
extends StateHfsm

signal game_retry

func _enter_tree() -> void:
	game_retry.connect(func():
		await get_tree().process_frame
		state_transition.emit(get_transition_state())
		)
