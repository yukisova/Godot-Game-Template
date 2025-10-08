## 过场剧情触发器
class_name InteractionCutscene
extends IInteraction

@export var cutscene: CutsceneNode

var info: Dictionary

func _ready() -> void:
	cutscene.cutscene_output.connect(func(output: Dictionary) -> void:
		info = output
	)

func __interact_begin(interactor: IEntity) -> bool:
	cutscene.cutscene_started.emit()
	await cutscene.cutscene_output
	await get_tree().process_frame
	return true

func __interact_reset() -> void:
	pass
