## @editing: Sora [br]
## @describe: 游戏的主控系统, 管理玩家的输入信息逻辑, 与主要控制对象(即玩家角色)
extends ISystem

signal player_located(target_level: Level, target_position: Vector2)

@export var player_scene: PackedScene
@export_subgroup("依赖")
@export var input_listener: InputListener

var player_static: Entity

func _setup():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
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

#region 移动
func _vec_input_2_toward() -> Dictionary:
	return {}

## 4向移动
func _vec_input_4_toward() -> Dictionary:
	var vec_info : Dictionary = {}
	if Input.is_action_pressed("move_l"):
		vec_info["vec"] = Vector2.LEFT
	elif Input.is_action_pressed("move_r"):
		vec_info["vec"] = Vector2.RIGHT
	elif Input.is_action_pressed("move_u"):
		vec_info["vec"] = Vector2.UP
	elif Input.is_action_pressed("move_d"):
		vec_info["vec"] = Vector2.DOWN
	else:
		vec_info["vec"] = Vector2.ZERO
	if (!vec_info["vec"].is_zero_approx()):
		vec_info["pre_vec"] = vec_info["vec"]
	return vec_info

func _vec_input_8_toward() -> Dictionary:
	var vec_info: Dictionary = {}
	vec_info["vec"] = Input.get_vector("move_l","move_r","move_u","move_d").sign()
	
	if (!vec_info["vec"].is_zero_approx()):
		vec_info["pre_vec"] = vec_info["vec"]
	return vec_info

## 全向移动
func _vec_input_a_toward() -> Dictionary:
	var vec_info : Dictionary = {}
	vec_info["vec"] = Input.get_vector("move_l","move_r","move_u","move_d")
	
	if (!vec_info["vec"].is_zero_approx()):
		vec_info["pre_vec"] = vec_info["vec"]
	return vec_info
#endregion
