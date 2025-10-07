## 过场剧情触发器
class_name InteractionCutscene
extends IInteraction

@export var cutscene: CutsceneNode

func _ready() -> void:
	cutscene.cutscene_output.connect(func(output: Dictionary) -> void:
		interact_output.emit(output)
	)

func __interact_begin(interactor: IEntity) -> void:
	cutscene.cutscene_started.emit()

func __interact_reset() -> void:
	pass
