## 层级子场景
class_name Level
extends Node2D

signal level_fully_loaded

var layers_count = 0
var layers_loaded_count = 0

# 附加到TileMap节点的脚本
func _enter_tree() -> void:
	# 等待所有子节点（TileMapLayer）初始化
	for layer in get_children():
		if layer is TileMapLayer:
			layer.ready.connect(_on_layer_ready, CONNECT_DEFERRED)
			layers_count += 1
	_check_all_layers_loaded()

func _on_layer_ready():
	layers_loaded_count += 1
	_check_all_layers_loaded()

func _check_all_layers_loaded():
	if layers_loaded_count == layers_count:
		level_fully_loaded.emit()
