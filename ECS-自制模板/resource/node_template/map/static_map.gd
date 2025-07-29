##@editing:	Sora
##@describe:	静态地图类, s_map_data处理的主要对象
class_name StaticMap
extends Node

@export var player_spawn: PlayerSpawn
@export var levels: Node2D
@export var autoload_cutscene: Node
@export var cutscene_ref: Dictionary[String, Variant]

var level_count: int = 0
var level_loaded_count :int = 0
var level_initialized_count : int = 0

func _ready() -> void:
	for level in levels.get_children():
		if level is Level:
			level.level_fully_loaded.connect(_on_level_fully_loaded)
			level.level_entity_fully_initialize.connect(_on_level_entity_fully_loaded)
			level_count += 1
	
	for cutscene in autoload_cutscene.get_children():
		SSignalBus.game_data_loaded_compelete.connect(cutscene._start.bind(cutscene_ref))

func _on_level_fully_loaded():
	level_loaded_count += 1
	if level_loaded_count == level_count:
		SSignalBus.map_info_loaded.emit.call_deferred()

func _on_level_entity_fully_loaded():
	level_initialized_count += 1
	if level_initialized_count == level_count:
		SSignalBus.game_data_loaded_compelete.emit.call_deferred()
