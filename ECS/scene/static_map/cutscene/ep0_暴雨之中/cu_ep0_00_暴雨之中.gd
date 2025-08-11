extends Cutscene

const dialogue_packed = preload("res://ui/ui/ui_dialogue/ui_dialogue.tscn")
const dialogue_resource = preload("res://resource/plugins_resource/dialogue/ep0_暴雨之中.dialogue")
const dialogue_label: Dictionary = {\
	"part_1":"ep0_地铁内_开场"\
	}
@export var dialogue_info: Dictionary[String, Variant]


func _start():
	SBlackboard.sub_systems["time_loop"].read_time = 511
	
	await SGameState.state_machine.state_transition_finished ## 此时还在执行Transition的_exit方法，因此要等待完全加载OK之后才可以进行正式的过场
	
	var transition = SUiSpawner.current_hud[&"transition"] as IHud

	
	var dialogue = SUiSpawner._spawn_ui(dialogue_packed)
	DialogueManager._start_balloon(dialogue, dialogue_resource, dialogue_label["part_1"], [_fixed_dialogue_info()])
	
	await DialogueManager.dialogue_ended


func _fixed_dialogue_info() -> Dictionary:
	var dialogue_info_fixed = dialogue_info.duplicate_deep()
	for key in dialogue_info_fixed:
		if dialogue_info_fixed[key] is NodePath:
			dialogue_info_fixed[key] = get_node(dialogue_info_fixed[key])
	return dialogue_info_fixed
