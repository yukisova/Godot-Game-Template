## 静态地图的管理
class_name StaticMap
extends Node

signal map_info_loaded

@export var player_spawn: PlayerSpawn
@export var levels: Node2D

var level_count: int = 0
var level_loaded_count :int = 0

func _ready() -> void:
	for level in levels.get_children():
		if level is Level:
			level.level_fully_loaded.connect(_on_level_fully_loaded)
			level_count += 1

func _on_level_fully_loaded():
	level_loaded_count += 1
	if level_loaded_count == level_count:
		map_info_loaded.emit()
