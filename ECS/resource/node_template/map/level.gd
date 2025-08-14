## @editing: Sora [br]
## @describe: 地图层级系统 - 静态地图中的单个层级管理
##
## 该类管理静态地图中的单个层级，负责：
## - 瓦片地图图层的加载和协调
## - 预设实体的初始化管理
## - 相机边界的限制设置
## - 房间碰撞体的组织
##
## 主要功能：
## - 异步加载瓦片图层和多边形瓦片
## - 监控预设实体的初始化状态
## - 提供相机限制的边界信息
## - 支持层级数据的存档和读档
##
## 设计特点：
## - 基于信号的异步加载机制
## - 统计驱动的完成度检测
## - 灵活的组件依赖管理
## - 层次化的数据组织结构
##
## 使用场景：
## - 多层建筑的楼层划分
## - 地下城的区域分割
## - 大型地图的区块管理
## - 不同高度层的视觉分离
class_name Level
extends Node2D

#region 层级信号

## 层级完全加载信号
## 当前层级的所有瓦片图层加载完毕后发出
signal level_fully_loaded

## 层级实体初始化完成信号
## 当前层级的所有预设实体初始化完毕后发出
signal level_entity_fully_initialize

#endregion

#region 层级组件

## 相机限制区域
## 用于限制玩家在该层级中的相机边界
@export var camera_limit: Control

## 房间碰撞体集合
## 包含该层级所有房间和区域的碰撞体信息
@export var room: Node2D

## 层级对象池
## 用于管理该层级中的临时实体，临时实体只会在当前层级生成，玩家离开当前层级后会将该层级中的临时实体统一销毁
@export var level_object_pool: Node2D

#endregion

#region 瓦片图层统计

## 瓦片图层总数
## 当前层级中瓦片地图的总数量
var layers_count = 0

## 已加载瓦片图层数
## 已完成加载的瓦片图层数量
var layers_loaded_count = 0

#endregion

#region 实体统计

## 预设实体总数
## 当前层级中预定义实体的总数量
var entity_count = 0

## 已初始化实体数
## 已完成初始化的预设实体数量
var entity_loaded_count = 0

#endregion

# 进入场景树: 对接瓦片的加载逻辑和预定义实体的初始化监听逻辑
func _enter_tree() -> void:
	for layer in get_children():
		if layer is TileMapLayer or layer is PolygonTile:
			layer.ready.connect(_on_layer_ready, CONNECT_DEFERRED)
			layers_count += 1
		elif layer is FixedEntity:
			layer.initialize_complete.connect(_on_entity_initialize)
			layer.is_entity_origin_exist = true
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

#region :存档系统:
func _save_as(_data: SavedDataFile) -> Dictionary:
	var levels_result = {}
	for element in get_children():
		if element.has_method("_save_as"):
			levels_result.merge(element._save_as(_data))
	return { name:levels_result }
	

func _load_by(data: SavedDataFile):
	var dict = data.map_info[name]
	for element in get_children():
		if element.has_method("_load_by"):
			element._load_by(data, dict[element.name])
#endregion
