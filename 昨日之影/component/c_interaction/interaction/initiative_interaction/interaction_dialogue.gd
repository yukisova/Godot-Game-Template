## @editing: Sora [br]
## @describe: 谈话交互,绑定DialogueManager，此时玩家会被硬控，游戏状态机进入cutscene状态
extends PassiveInteraction

@export var test_dialogue_ui: PackedScene
@export var test_dialogue: DialogueResource
@export var test_dialogue_label: StringName

func _on_interact_activated(_target_entity: Entity, _component: IComponent):
	var dialogue = SUiSpawner._spawn_ui(test_dialogue_ui)
	DialogueManager._start_balloon(dialogue, test_dialogue, test_dialogue_label, [])
	
func _on_interact_deactivated(_component: IComponent):
	pass
