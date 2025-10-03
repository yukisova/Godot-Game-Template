extends ISystem

signal map_registered(map: PackedScene, data: SavedDataFile)
signal map_regist_finished
signal map_changed(map: PackedScene, located_info: Dictionary)
signal map_changed_finished
signal level_changed(operate_entity: FixedEntity, new_level: Level, point: Vector2)
signal level_changed_finished_for_player()

var current_map: StaticMap
var current_level: Level:
	set(value):
		if value != null or current_level == null:
			current_level = value
		elif is_instance_valid(current_level):
			return
		else:
			current_level = null

func _enter_tree() -> void:
	map_registered.connect(_on_map_registered)
	level_changed.connect(_on_level_changed)
	map_changed.connect(_on_map_changed)

func _setup():
	pass

func _resetup():
	if current_map:
		current_map.queue_free()

## 地图注册，用于初始化地图的数据
## FIXME 1. 当存在多个层级的时候，会导致无法正确显示目标层级
## 2. 
func _on_map_registered(_data: SavedDataFile):
	await get_tree().process_frame

	var map_scene = ResourceLoader.load(_data.map_cache["current_map"]) as PackedScene
	var map = map_scene.instantiate() as StaticMap

	current_map = map

	SUiSpawner._hide_all_hud(["transition"])
	Main.game_view.add_child(map)
	## 等待地图数据完成加载
	await SSignalBus.map_info_loaded
	## 暂时禁用所有的层级碰撞导航，避免在加载玩家出生点的时候，出现矛盾问题
	for level in map.levels.get_children():
		if level is Level:
			level.initialize_collision_navigation_states()
			level.disable_all_collision_navigation()
	
	## 根据存档中的数据，获取玩家当前所在的层级
	current_level = current_map.get_node(_data.map_cache["current_level"] as NodePath)
	# 启用当前层的碰撞和导航
	current_level.enable_all_collision_navigation()
	SMainController.player_located.emit.call_deferred(current_level, _data.player_info)

	map_regist_finished.emit()

func _on_level_changed(operate_entity: FixedEntity, new_level: Level, point: Vector2):
	if new_level == current_level:
		operate_entity.global_position = point
		operate_entity.main_control.global_position = point
		return
	if operate_entity.main_control.is_in_group("player"):
		current_level.disable_all_collision_navigation()
		SObjectPool.level_pool_cleared.emit(current_level)

		operate_entity.global_position = point
		operate_entity.main_control.global_position = point

		SViewportManager.set_camera_limit(new_level.get_camera_limit())
		
		new_level.enable_all_collision_navigation()
		current_level = new_level
		level_changed_finished_for_player.emit.call_deferred()
	
	operate_entity.reparent(new_level)
	new_level._process_all_collision_navigation_recursive(operate_entity, true)

func map_info_preload(map_scene: PackedScene) -> Dictionary:
	await get_tree().process_frame

	var map_cache = {
		"current_map": map_scene.resource_path
	}
	var player_info = {
		"type": "Initialize",
	}

	current_map = map_scene.instantiate() as StaticMap
	SUiSpawner._hide_all_hud(["transition"])
	Main.game_view.add_child(current_map)

	await SSignalBus.map_info_loaded

	## 暂时禁用所有的层级碰撞导航，避免在加载玩家出生点的时候，出现矛盾问题
	for level in current_map.levels.get_children():
		if level is Level:
			level.initialize_collision_navigation_states()
			level.disable_all_collision_navigation()

	var spawns: Array[PlayerSpawn] = current_map.player_spawns

	if !spawns.is_empty():
		var spawn_info = {}
		for i in spawns.size():
			var spawn = spawns[i]
			if spawn == null: continue
			var new_record = {
				i:{
					"start_position":spawn.global_position,
					"current_position":spawn.global_position,
					"current_room":spawn.current_room.get_path(),
					"current_level":spawn.current_room.get_belongs_level().get_path(),
				}
			}
			spawn_info.merge(new_record)
		player_info["spawn_info"] = spawn_info
		## 根据存档中的数据，获取玩家当前所在的层级
		current_level = current_map.get_node(player_info["spawn_info"][0]["current_level"] as NodePath)
		SMainController.player_located.emit.call_deferred(current_level, player_info)
	else:
		push_error("地图数据: 未检测到玩家出生点，请检查地图配置")

	# 启用当前层的碰撞和导航
	current_level.enable_all_collision_navigation()
	map_regist_finished.emit()
	
	return {
		"player_info": player_info,
		"map_cache": map_cache,
	}

func _on_map_changed(target_map: PackedScene, located_info: Dictionary):
	var player_statics = SMainController.player_static

	if !player_statics.is_empty():

		for player_static in player_statics.values():
			current_level.remove_child(player_static)

		current_map.queue_free()
		current_map = target_map.instantiate()
		Main.game_view.add_child(current_map)
		await SSignalBus.map_info_loaded
			
		for level in current_map.levels.get_children():
			if level is Level:
				level.initialize_collision_navigation_states()
				level.disable_all_collision_navigation()

		var target_point: TransportPoint
		if located_info.get("target_level_name", &"") != &"" or located_info.get("target_level_index", -1) != -1:
			current_level = current_map.get_level_by_name(located_info["target_level_name"])
			current_level = current_map.get_level_by_index(located_info["target_level_index"])
			if current_level:
				target_point = current_level.transport_point_list.get(located_info.get("target_key", &""), null)
			else:
				push_warning("地图数据: 未检测到目标楼层，请检查地图配置")
				return
		else:
			target_point = current_map.exported_transport_points.get(located_info.get("target_key", &""), null)
			if target_point:
				current_level = target_point.get_parent() as Level
			else:
				push_warning("地图数据: 未检测到传送点，请检查地图配置")
				return
		
		current_level.enable_all_collision_navigation()

		SMainController.player_located.emit.call_deferred(current_level, {
			"type": "Transport",
			"target_level": current_level,
			"target_point": target_point,
		})

		map_changed_finished.emit()

		SViewportManager._refresh_viewports()
		SViewportManager.set_camera_limit(current_level.get_camera_limit())
		
func get_map_cache(key: String, default):
	if current_map:
		return current_map.cache_in_map.get_or_add(key, default)
	else:
		return default

func set_map_cache(key: String, value, set_type: int = 0):
	if current_map:
		match set_type:
			0: 
				current_map.cache_in_map[key] = value
			1: 
				current_map.cache_in_map[key] += value
			2: 
				current_map.cache_in_map[key] -= value

#region :存档系统集成:
func _data_saving(data: SavedDataFile):
	var map_cache = {
		"cache_in_map": current_map.cache_in_map,
		"current_map": current_map.scene_file_path,
		"current_level": current_map.get_path_to(current_level)
	}
	
	data.map_cache = map_cache
	
	current_map._save(data)

func _data_loading(_data: SavedDataFile):
	SMapData.map_registered.emit(load(_data.map_cache["current_map"]) as PackedScene, _data)
	await SSignalBus.map_info_loaded
	current_map.cache_in_map = _data.map_cache["cache_in_map"]
#endregion
