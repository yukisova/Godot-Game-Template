## 传送交互 - 实现实体在不同场景间的传送功能
## 支持地图间传送和楼层间传送，可使用索引或名称指定目标位置
## [br][b]编辑者:[/b] Sora
## 
@tool
class_name InteractionTransport
extends IInteraction

## 如果为空的话，则是基于当前场景进行传送
@export_group("选填参数")
@export_file_path("*.tscn") var target_map_path: String = "" ## 目标地图路径
@export var target_key: String ## 目标传送点的标识键
@export var target_node: Node2D

var temp_disable: bool = false:
	set(value):
		if value:
			temp_disable = true
			await get_tree().create_timer(1.0).timeout
			temp_disable = false

func __interact_begin(interactor: IEntity) -> bool:

	while temp_disable and _check_collision():
		await get_tree().create_timer(1).timeout
	
	### 有可能经过循环延迟后，物体已经离开碰撞区域，因此需要进行再次检查
	#if ! _check_collision():
		#return

	var map_to_load: PackedScene 
	
	# 如果没有直接引用但有路径，则动态加载
	if target_map_path != "":
		map_to_load = load(target_map_path)
	
	if map_to_load != null:
		SMapData.map_changed.emit(map_to_load, {
			"target_key": target_key
		})
	else:
		if target_node != null:
			SMapData.level_changed.emit(interactor, target_node)
		else:
			push_error("传送时未检测到目标楼层，请检查传送点配置")
	
	return true

func __interact_reset() -> void:
	pass

func _check_collision() -> bool:
	return false
