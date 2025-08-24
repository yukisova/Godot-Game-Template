extends ICutscene

## 对话UI场景
const dialogue_packed = preload("res://ui/ui/ui_dialogue/ui_dialogue.tscn")

## 对话资源
const dialogue_resource = preload("res://resource/plugins_resource/dialogue/sight_light_索拉的世界.dialogue")

## 对话标签字典
const dialogue_label: Dictionary = {\
	"part_0":"start",\
	"part_1":"开场",\
	"part_2":"结束"\
	}

## 对话信息配置
## 传递给对话系统的上下文数据
@export var dialogue_info: Dictionary[String, Variant]


const ui_game_over = preload("res://ui/ui/ui_game_over/ui_game_over.tscn")

func _start() -> void:
	var transition = SUiSpawner.current_hud[&"transition"] as IHud
	transition.fade_out()

	var dialogue = SUiSpawner._spawn_ui(dialogue_packed, {}, true)
	DialogueManager._start_balloon(dialogue, dialogue_resource, dialogue_label["part_2"], [SoraEvent.fixed_dictionary(self ,dialogue_info)])

	await DialogueManager.dialogue_ended

func _finished() -> void:
	var game_over = SUiSpawner._spawn_ui(ui_game_over, {}, true)
	game_over.show()
