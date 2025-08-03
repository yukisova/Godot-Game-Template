## @editing: Sora [br]
## @describe: 游戏的过场剧情阶段，该状态下玩家可以进入暂停状态， 即打开菜单，但不可以实现打开角色状态界面
@tool
class_name GamingStateCutscene
extends StateHfsm
	
signal game_retryed

func _enter_tree() -> void:
	game_retryed.connect(func():
		await get_tree().process_frame
		state_transition.emit(get_transition_state())
		)
