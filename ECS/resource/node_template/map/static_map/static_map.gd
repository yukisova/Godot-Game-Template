@tool
class_name StaticMap
extends Node

#region 玩家配置

@export var bg_music: AudioStream

@export_file_path("*.tscn") var decal_path: String

## 玩家出生点
## 指定玩家在此地图中的初始位置和层级，类型为 [PlayerSpawn]
@export var player_spawns: Array[PlayerSpawn]

@export_range(0,1) var default_time: float

#endregion

#region 地图组件依赖

@export_subgroup("依赖")

@export var levels: Node2D

var levels_array: Array[Level]

@export var autoload_cutscene: Node

@export var cutscene_enable: bool = true

var exported_transport_points: Dictionary[StringName, TransportPoint] = {}

#endregion

#region 地图数据

var cache_in_map: Dictionary

#endregion

#region 加载状态统计

var level_count: int = 0

var level_loaded_count: int = 0

var level_initialized_count: int = 0

#endregion

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return

	for level in levels.get_children():
		if level is Level:
			# 创建一个子视口，用于隔离level的渲染
			var viewport = SubViewport.new()
			levels.add_child(viewport)
			level.reparent.call_deferred(viewport)
			levels_array.append(level)

			level.level_fully_loaded.connect(_on_level_fully_loaded)
			level.level_entity_fully_initialize.connect(_on_level_entity_fully_loaded)
			level.static_map = self
			level_count += 1
	
	if cutscene_enable:
		for cutscene in autoload_cutscene.get_children():
			SSignalBus.game_loop_start.connect(func(): cutscene.cutscene_started.emit())
		SSignalBus.game_loop_start.connect(_on_game_loop_start)
	else:
		SSignalBus.game_loop_start.connect(_on_game_loop_start)

func _on_game_loop_start():
	## 初始化所有层级的后期组件—确保迷雾和房间系统正确初始化
	for level in levels_array:
		level._late_initialize()
	## 根据预设配置决定调试模式
	var debug = SCommandParser.debug_setting
	if !(debug & SCommandParser.DebugFlag.无bgm):
		SAudioMaster.play_music(bg_music)
	if !(debug & SCommandParser.DebugFlag.无时间概念):
		pass
	
	## 注册当前层级的血迹Decal地板对象池
	if decal_path:
		var decal_scene: PackedScene = load(decal_path)
		SObjectPool.register_pool("decal", decal_scene, 10)
	SUiSpawner._get_hud("transition").try_show()
	SUiSpawner._get_hud("transition").fade_in()

func _on_level_fully_loaded():
	level_loaded_count += 1
	if level_loaded_count == level_count:
		SSignalBus.map_info_loaded.emit.call_deferred()

func _on_level_entity_fully_loaded():
	level_initialized_count += 1
	if level_initialized_count == level_count:
		SSignalBus.game_data_loaded_compelete.emit.call_deferred()

#region :存档系统:
func _save(data: SavedDataFile):
	var map_result = {}
	for level: Level in levels.get_children():
		map_result.merge(level._save_as(data))
	
	data.level_info = map_result
#endregion
