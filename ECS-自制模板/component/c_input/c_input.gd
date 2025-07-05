## 
@tool
class_name C_Input
extends IComponent

@export_enum("横版", "四向", "八向", "全向") var award_mode: String = "四向"

## 游戏的装备等游戏内信息相关的设置菜单
@export var brain_ui: PackedScene
## 游戏的设置，游戏的退出等游戏外相关的设置菜单
@export var pause_ui: PackedScene

enum ControlMode{ just_pressed = 0, pressed, just_release }

func _enter_tree() -> void:
	component_name = ComponentName.c_input

func _initialize(_owner: Entity):
	super._initialize(_owner)

func _update(_delta: float):
	if component_body.is_in_group("player"):
		if Main.s_game_state.state_machine._get_leaf_state() is GamingStateNormal:
			_ui_trigger()

func validate_control(key_string: StringName, control_mode: ControlMode = ControlMode.just_pressed) -> bool:
	if (S_GlobalConfig.is_initialized):
		match control_mode:
			ControlMode.just_pressed:
				return Input.is_action_just_pressed(key_string)
			ControlMode.pressed:
				return Input.is_action_pressed(key_string)
			ControlMode.just_release:
				return Input.is_action_just_released(key_string)
	return false

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
	return {}

## 全向移动
func _vec_input_a_toward() -> Dictionary:
	var vec_info : Dictionary = {}
	vec_info["vec"] = Input.get_vector("move_l","move_r","move_u","move_d")
	
	if (!vec_info["vec"].is_zero_approx()):
		vec_info["pre_vec"] = vec_info["vec"]
	return vec_info

func try_input_vector() -> Dictionary:
	if (S_GlobalConfig.is_initialized):
		match award_mode:
			"横版":
				pass
			"四向":
				return _vec_input_4_toward()
			"八向":
				pass
			"全向":
				return _vec_input_a_toward()
			_:
				push_error("输入有问题")
	return {}
#endregion

#region 测试用触发功能
func _try_save_game():
	if (Input.is_action_just_pressed("test_saving")):
		Main.s_load_and_save.emit_signal("saving_started")
		print("文件已经完成存储")

#endregion

#region Ui触发逻辑
## TODO 玩家Ui触发: 在input组件内设计了Ui触发的逻辑，只允许在gaming_normal的阶段运行
func _ui_trigger():
	if Input.is_action_just_pressed("brain_trigger"):
		Main.s_ui_spawner.call("_spawn_ui", brain_ui)
	elif Input.is_action_just_pressed("pause_game"):
		Main.s_ui_spawner.call("_spawn_ui", pause_ui)
#endregion
