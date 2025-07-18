## 触发交谈事件，此时玩家会被硬控，游戏状态机进入cutscene状态
extends Interaction

@export var dialogue: DialogueResource
@export var dialogue_label: String

const ui_dialogue: PackedScene = preload("res://ui/ui/ui_dialogue/ui_dialogue.tscn")

func _on_interact_activated(_component: IComponent):
	var ui = Main.s_ui_spawner._spawn_ui(ui_dialogue) as UiDialogue
	
	
