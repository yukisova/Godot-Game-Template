extends ISystem

signal factor_added(new_factor: Entity, start_position: Vector2)
signal map_info_registered(map: PackedScene)

@export var test_start_map_scene: PackedScene ## 要加载的地图

var current_level: Level

func _enter_tree() -> void:
	factor_added.connect(_on_factor_added)
	map_info_registered.connect(_on_map_info_registered)

func _setup():
	pass

## 地图场景重加载
func _on_map_info_registered(map_scene: PackedScene):
	await get_tree().process_frame
	var map = map_scene.instantiate() as StaticMap
	Main.game_view.add_child(map)
	
	## 当地图完成加载后，发送map_info_loaded信号，表明当前已经完成了所有地图信息的加载
	await SSignalBus.map_info_loaded
	
	var spawn = map.player_spawn
	if (spawn != null):
		current_level = spawn.current_level
		SPlayerStatic.player_located.emit.call_deferred(spawn.current_level , spawn.global_position)
		spawn.queue_free()

## 地图元素新建
func _on_factor_added(new_factor: Entity, start_position: Vector2):
	current_level.add_child.call_deferred(new_factor)
	new_factor.main_control.global_position = start_position
	new_factor._initialize()
