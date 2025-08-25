## 过场剧情触发器

extends Interaction

var cutscenes: Array[ICutscene]

func _ready() -> void:
	for cutscene in get_children():
		if cutscene is ICutscene:
			cutscenes.append(cutscene)

func __interact_begin(interactor: IEntity) -> void:
	for cutscene in cutscenes:
		cutscene.start()

func _on_interact_deactivated() -> void:
	pass