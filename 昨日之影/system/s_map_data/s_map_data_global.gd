## @editing: Sora [br]
## @describe: 地图信息加载系统，代替了原本常用的scene_change
extends ISystem

signal factor_added(new_factor: Entity, start_position: Vector2)
signal map_info_registered(map: PackedScene)
signal level_changed(operate_entity: Entity,new_level: Level)

@export var test_start_map_scene: PackedScene ## 要加载的地图

var current_level: Level
var current_map: StaticMap

func _enter_tree() -> void:
	factor_added.connect(_on_factor_added)
	map_info_registered.connect(_on_map_info_registered)
	level_changed.connect(_on_level_changed)

func _setup():
	pass

func _resetup():
	current_level = null
	current_map.queue_free()

## 地图场景加载
func _on_map_info_registered(map_scene: PackedScene):
	await get_tree().process_frame
	var map = map_scene.instantiate() as StaticMap
	current_map = map
	
	Main.game_view.add_child(map)
	
	## 当地图完成加载后，发送map_info_loaded信号，表明当前已经完成了所有地图信息的加载
	await SSignalBus.map_info_loaded
	
	var spawn = map.player_spawn
	if (spawn != null):
		for i:Node in map.levels.get_children():
			i.process_mode = Node.PROCESS_MODE_DISABLED
			i.hide()
		
		current_level = spawn.current_level
		current_level.process_mode = Node.PROCESS_MODE_INHERIT
		current_level.show()
			
		SMainController.player_located.emit.call_deferred(spawn.current_level , spawn.global_position)
		spawn.queue_free()
	else:
		push_warning("没有检测到角色出生点，最好再检查一下")

## 地图元素新建
func _on_factor_added(new_factor: Entity, start_position: Vector2):
	current_level.add_child.call_deferred(new_factor)
	new_factor.main_control.global_position = start_position
	new_factor._initialize()

## 切换层级
func _on_level_changed(operate_entity: Entity,new_level: Level):
	if operate_entity.main_control.is_in_group("player"):
		current_level.hide()
		current_level.process_mode = Node.PROCESS_MODE_DISABLED
		var camera = operate_entity.list_base_components.get(IComponent.ComponentName.c_camera) as C_Camera
		camera.set_camera_limit(new_level.get_camera_limit())
		new_level.show()
		new_level.process_mode = Node.PROCESS_MODE_INHERIT
		current_level = new_level
		
	operate_entity.reparent(new_level)
