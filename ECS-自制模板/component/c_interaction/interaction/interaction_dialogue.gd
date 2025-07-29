##@editing:	Sora
##@describe:	谈话交互,绑定DialogueManager，此时玩家会被硬控，游戏状态机进入cutscene状态
##			HACK 谈话的对话框希望在ui_view中
extends Interaction

@export var dialogue: DialogueResource
@export var dialogue_label: String

const ui_dialogue_scene: PackedScene = preload("res://ui/ui/ui_dialogue/ui_dialogue.tscn")

func _on_interact_activated(_component: IComponent):
	var ui_dialogue = ui_dialogue_scene.instantiate()
	DialogueManager._start_balloon(ui_dialogue, dialogue, dialogue_label, [])
	
func _on_interact_deactivated(_component: IComponent):
	pass
