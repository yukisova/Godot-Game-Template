##@editing:	Sora
##@describe:	静态方法工具类
class_name SoraEvent
extends Node

const DIALOGUE_BALLOON: PackedScene = preload("res://ui/ui/ui_dialogue/ui_dialogue.tscn")
## 经过包装之后的dialogue start
static func sora_dialogue_start(dialogue: DialogueResource ,_label: String = "", _context: Array = []):
	var balloon = DIALOGUE_BALLOON.instantiate()
	DialogueManager._start_balloon(balloon, dialogue, _label, _context)
