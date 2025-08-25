## 传送交互 - 实现实体在不同场景间的传送功能
## 支持地图间传送和楼层间传送，可使用索引或名称指定目标位置
## [br][b]编辑者:[/b] Sora
## 
@tool
class_name InteractionTransport
extends Interaction

@export var target_level_index: int = -1 ## 目标传送层级索引，-1表示不使用
@export var target_level_name: StringName = &"" ## 目标传送层级名称，空串表示不使用
@export var target_key: String ## 目标传送点的标识键

## 如果为空的话，则是基于当前场景进行传送
@export_group("选填参数")
@export_file_path("*.tscn") var target_map_path: String = "" ## 目标地图路径

func __interact_begin(interactor: IEntity) -> void:
	var map_to_load: PackedScene 
	
	# 如果没有直接引用但有路径，则动态加载
	if target_map_path != "":
		map_to_load = load(target_map_path)
	
	if map_to_load != null:
		SMapData.map_changed.emit(map_to_load, {
			"target_level_name": target_level_name,
			"target_level_index": target_level_index,
			"target_key": target_key
		})
	else:
		var target_level: Level
		if target_level_index != -1:
			target_level = SMapData.current_map.get_level_by_index(target_level_index)
		elif target_level_name != &"":
			target_level = SMapData.current_map.get_level_by_name(target_level_name)
		else:
			target_level = SMapData.current_level

		if target_level != null:
			SMapData.level_changed.emit(interactor, target_level, binding_entity.global_position)
		else:
			push_error("传送时未检测到目标楼层，请检查传送点配置")

func _on_interact_deactivated() -> void:
	pass
