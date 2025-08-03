## @editing: Sora [br]
## @describe: 静态地图里的层级系统
class_name Level
extends Node2D

signal level_fully_loaded ## 当前层级的所有TilemapLayer加载完毕后发出
signal level_entity_fully_initialize ## 判断当前层级的实体是否初始化完毕

@export var camera_limit: Control
@export var room: Node2D

## 当前层中, 瓦片Tilemap的数目
var layers_count = 0
var layers_loaded_count = 0

## 当前层中，预定义Entity的数目
var entity_count = 0
var entity_loaded_count = 0

# 进入场景树: 对接瓦片的加载逻辑和预定义实体的初始化监听逻辑
func _enter_tree() -> void:
	for layer in get_children():
		if layer is TileMapLayer or layer is PolygonTile:
			layer.ready.connect(_on_layer_ready, CONNECT_DEFERRED)
			layers_count += 1
		elif layer is Entity:
			layer.initialize_complete.connect(_on_entity_initialize)
			entity_count += 1
	_check_all_layers_loaded()

func _on_layer_ready():
	layers_loaded_count += 1
	_check_all_layers_loaded()

func _on_entity_initialize():
	entity_loaded_count += 1
	_check_all_entity_initialize()

func _check_all_layers_loaded():
	if layers_loaded_count == layers_count:
		level_fully_loaded.emit()


func _check_all_entity_initialize():
	if entity_loaded_count == entity_count:
		level_entity_fully_initialize.emit()


func get_camera_limit() -> Dictionary:
	var limit_dict = {}
	var rect = camera_limit.get_global_rect()
	limit_dict["camera_top"] = rect.position.y
	limit_dict["camera_left"] = rect.position.x
	limit_dict["camera_right"] = rect.end.x
	limit_dict["camera_bottom"] = rect.end.y
	return limit_dict
