class_name S_Mapdata
extends ISystem

signal factor_added(new_factor: Entity, start_position: Vector2)
signal map_info_registered(map: PackedScene)

@export var test_start_map_scene: PackedScene ## 要加载的地图

var current_level: Level

func _enter_tree() -> void:
	Main.s_map_data = self
	
	factor_added.connect(_on_factor_added)
	map_info_registered.connect(_on_map_info_registered)

func _setup():
	if Launcher.main.name.contains("Test"):
		map_info_registered.emit(test_start_map_scene)

## 地图场景重加载
func _on_map_info_registered(map_scene: PackedScene):	
	var map = map_scene.instantiate()
	Launcher.main.game_view.add_child(map)

	var s_player_static = Main.s_player_static
	var spawn = map.player_spawn
	if (spawn != null):
		current_level = spawn.current_level
		s_player_static.player_located.emit.call_deferred(spawn.current_level , spawn.global_position)
		spawn.queue_free()
	Main.s_game_state.emit_signal("gamedata_loaded")

## 地图元素新建
func _on_factor_added(new_factor: Entity, start_position: Vector2):
	current_level.add_child.call_deferred(new_factor)
	new_factor.main_control.global_position = start_position
	new_factor._initialize()
