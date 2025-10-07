class_name REMovementInput
extends ReactorExtension

enum MoveMode {
	HORIZONTAL, ## 横版
	FOUR_DIRECTION, ## 四向
	EIGHT_DIRECTION, ## 八向
	A_DIRECTION, ## 全向
	MOUSE, ## 鼠标长按
	MOUSE_CLICK, ## MOBA
}
enum TowardMode {
	MOVE, ## 跟随移动方向
	MOUSE, ## 面向鼠标方向
}

@export var award_mode: MoveMode = MoveMode.FOUR_DIRECTION
@export var toward_mode: TowardMode = TowardMode.MOVE:
	set(v):
		toward_mode = v

@export_flags("向量监听") var disable_flag: int:
	set(v):
		disable_flag = v
		notify_property_list_changed()

var input_vector_dict: Dictionary[String, Vector2] = {
	"move" : Vector2.ZERO,
	"toward" : Vector2.ZERO
}

func _enter_tree() -> void:
	extention_type = REType.MOVEMENT_INPUT

func get_move_vector() -> Vector2:
	return input_vector_dict.move

func get_toward_vector() -> Vector2:
	return input_vector_dict.toward

#region 输入向量处理
func try_input_vector() -> Dictionary:
	var entity_input_target: SoraConstant.InputTarget = SMainController.get_input_target(c_input_reactor.component_owner)
	if (SGlobalConfig.is_initialized):
		match award_mode:
			MoveMode.HORIZONTAL:
				return SMainController._vec_input_2_toward(entity_input_target)
			MoveMode.FOUR_DIRECTION:
				return SMainController._vec_input_4_toward(entity_input_target)
			MoveMode.EIGHT_DIRECTION:
				return SMainController._vec_input_8_toward(entity_input_target)
			MoveMode.A_DIRECTION:
				return SMainController._vec_input_a_toward(entity_input_target)
			MoveMode.MOUSE:
				return SMainController._vec_input_m_toward(entity_input_target)
			_:
				push_error("未设定对应移动模式: " , award_mode)
	return {}

func _try_vector_control() -> Dictionary:
	if (SGlobalConfig.is_initialized):
		var input_move_info: Dictionary = try_input_vector()
		return input_move_info
	else:
		return {}
#endregion

func _late_initialize():
	pass

func _listen():
	var input_vector_dict_update: Dictionary = _try_vector_control()
	var current_move = input_vector_dict_update.get("vec", Vector2.ZERO) as Vector2

	input_vector_dict.move = current_move
	if input_vector_dict_update.has("pre_vec"):
		var current_toward = input_vector_dict_update.get("pre_vec", Vector2.ZERO) as Vector2
		input_vector_dict.toward = current_toward
