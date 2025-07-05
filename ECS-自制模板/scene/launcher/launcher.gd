## 启动器类，在其中设定游戏的启动进程
@tool
class_name Launcher
extends Node
enum GameMode {Main_Game, Test_Game}

@export var mode: GameMode :
	set(value):
		mode = value
		notify_property_list_changed()
	get:
		return mode
@export var main_game: PackedScene
@export var test_game: PackedScene

static var main: Main ## 主游戏进程


func _ready() -> void:
	if (Engine.is_editor_hint()):
		return
	match mode:
		GameMode.Main_Game:
			main = main_game.instantiate()
		GameMode.Test_Game:
			main = test_game.instantiate()
	add_child(main)


func _validate_property(property: Dictionary) -> void:
	match mode:
		GameMode.Main_Game:
			if property.name == "test_game":
				property.usage = PROPERTY_USAGE_NO_EDITOR
		GameMode.Test_Game:
			if property.name == "main_game":
				property.usage = PROPERTY_USAGE_NO_EDITOR
