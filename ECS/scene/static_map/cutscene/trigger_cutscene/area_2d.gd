## 触发的游戏结束剧情，如果晚上没有搞定的话，这是下下策
## FIXME: 这是临时的逻辑，是下下策
extends Area2D

@export var cutscene: ICutscene

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		cutscene.cutscene_started.emit()
