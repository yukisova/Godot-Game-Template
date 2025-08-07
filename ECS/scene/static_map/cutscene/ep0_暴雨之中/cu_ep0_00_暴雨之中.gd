extends Cutscene

const dialogue_packed = preload("res://ui/ui/ui_dialogue/ui_dialogue.tscn")
const dialogue_resource = preload("res://resource/plugins_resource/dialogue/ep0_暴雨之中.dialogue")
const dialogue_label = "ep0_地铁内_开场"

func _start():
	await SGameState.state_machine.state_transition_finished ## 此时还在执行Transition的_exit方法，因此要等待完全加载OK之后才可以进行正式的过场
	
	var transition = SUiSpawner.current_hud[&"transition"] as IHud

	
	var dialogue = SUiSpawner._spawn_ui(dialogue_packed)
	DialogueManager._start_balloon(dialogue, dialogue_resource, dialogue_label, [])
	
	await DialogueManager.dialogue_ended
