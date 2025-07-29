extends ISystem

signal player_located(target_level: Level, target_position: Vector2)

@export var player_scene: PackedScene
@export_subgroup("依赖")
@export var input_listener: InputListener

static var player_static: Entity

func _setup():
	player_located.connect(_on_player_located)

func _on_player_located(target_level: Level, target_position:Vector2):
	if (player_static != null):
		player_static.reparent(target_level)
		player_static.main_control.global_position = target_position
	else:
		player_static = player_scene.instantiate()
		player_static.main_control.global_position = target_position
		target_level.add_child(player_static)
	
	target_level.entity_count += 1 ## 目标的target_level新加了玩家，因此要进行额外的判断
	
	player_static.initialize_complete.connect(func():
		target_level._on_entity_initialize()
		SUiSpawner.current_hud[&""].binding_entity = player_static
		SUiSpawner.current_hud[&""]._initialize()
	)
	
	SSignalBus.entity_initialize_started.emit()
