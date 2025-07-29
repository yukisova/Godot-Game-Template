## 层级子场景
class_name Level
##@editing:	Sora
##@describe:静态地图里的层级系统
extends Node2D

signal level_fully_loaded
signal level_entity_fully_initialize ## 判断当前层级的实体是否初始化完毕

var layers_count = 0
var layers_loaded_count = 0

var entity_count = 0
var entity_loaded_count = 0

# 附加到TileMap节点的脚本
func _enter_tree() -> void:
	for layer in get_children():
		if layer is TileMapLayer:
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
