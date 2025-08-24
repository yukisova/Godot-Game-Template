## 过场剧情基类 - 定义过场剧情的抽象接口
## 该抽象类为所有过场剧情提供统一的框架和启动方法
@abstract class_name ICutscene
extends Node

signal cutscene_started
signal cutscene_ended

func _ready() -> void:
	cutscene_started.connect(_on_cutscene_started)
	cutscene_ended.connect(_on_cutscene_ended)

@abstract func _start()
@abstract func _finished()

func _on_cutscene_started() -> void:
	var current_state = SGameState.state_machine._get_leaf_state()
	if current_state is GamingStateNormal:
		current_state.game_cutscene_started.emit()
		await current_state.belong_state_machine.state_transition_finished
	elif current_state is not GamingStateCutscene:
		push_error("过场剧情只能在正常游戏状态或过场剧情状态中启动, 目前状态为: ", current_state)
		return
	await _start()
	await get_tree().process_frame
	cutscene_ended.emit.call_deferred()


func _on_cutscene_ended() -> void:
	var current_state = SGameState.state_machine._get_leaf_state()
	if current_state is GamingStateCutscene:    
		current_state.game_retryed.emit()
		await current_state.belong_state_machine.state_transition_finished
	else:
		push_error("过场剧情只能在过场剧情状态中结束， 目前状态为: ", current_state)
	await _finished()
