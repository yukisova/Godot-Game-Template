## @editing: Sora [br]
## @describe: 游戏的进行状态，该状态下 [br]
##			1. 运行游戏逻辑，玩家可以进行移动 [br]
##			2. 显示玩家的hud [br]
##			退出条件： [br]
##			1. 暂停信号 [br]
##			2. 进入过场剧情
@tool
class_name GamingStateNormal
extends StateHfsm

signal game_paused
signal game_cutscene_started

func _ready() -> void:
	game_paused.connect(func():
		await get_tree().process_frame
		state_transition.emit(get_transition_state("pause"))
		)
	game_cutscene_started.connect(func():
		await get_tree().process_frame
		state_transition.emit(get_transition_state("cutscene"))
		)

func _enter():
	SUiSpawner.current_hud[&""]._refresh()
	SUiSpawner.current_hud[&""].show()
	

func _exit():
	SUiSpawner.current_hud[&""].hide()
