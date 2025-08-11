## @editing: Sora [br]
## @describe: 谈话交互,绑定DialogueManager，此时玩家会被硬控，游戏状态机进入cutscene状态
extends PassiveInteraction

@export var test_dialogue_ui: PackedScene
@export var test_dialogue: DialogueResource
@export var test_dialogue_label: StringName
@export var dialogue_info: Dictionary[String, Variant]

func _fixed_dialogue_info() -> Dictionary:
	var dialogue_info_fixed = dialogue_info.duplicate_deep()
	for key in dialogue_info_fixed:
		if dialogue_info_fixed[key] is NodePath:
			dialogue_info_fixed[key] = get_node(dialogue_info_fixed[key])
	return dialogue_info_fixed

func _on_interact_activated(_target_entity: IEntity):
	var dialogue = SUiSpawner._spawn_ui(test_dialogue_ui)
	DialogueManager._start_balloon(dialogue, test_dialogue, test_dialogue_label, [_fixed_dialogue_info(),{"target_entity": _target_entity}])
	
func _on_interact_deactivated():
	pass
