## SORA @editing: Sora [br]
## @describe: 可控制组件，拥有该组件的实体可以被操控，但细节层面可以进行优化
@tool
class_name C_InputReactor
extends IComponent

enum ControlMode{ just_pressed = 0, pressed, just_release }
@export_enum("横版", "四向", "八向", "全向") var award_mode: String = "四向"
## 游戏的装备等游戏内信息相关的设置菜单
@export var brain_ui: PackedScene
## 游戏的设置，游戏的退出等游戏外相关的设置菜单
@export var pause_ui: PackedScene

@export_flags("向量监听","主控") var disable_flag: int:
	set(v):
		disable_flag = v
		notify_property_list_changed()

var input_vector_dict: Dictionary[String, Vector2] = {
	"move" : Vector2.ZERO
}
var reactor_extension: Array[ReactorExtension] = []

var interact_obj: C_Interactable = null:
	set(v):
		if v == null:
			print("可交互对象重置")
		else:
			print("可交互对象更新: ", v.component_owner.name)
		interact_obj = v

func _enter_tree() -> void:
	component_name = ComponentName.c_input_reactor

func _initialize(_owner: Entity):
	super._initialize(_owner)
	
	if component_owner == SMainController.player_static:
		SMainController.input_listener.binding_input_component = self
		disable_flag |= 0b010
	
	for i in get_children():
		if i is ReactorExtension:
			reactor_extension.append(i)
			i.binding_entity = component_owner
			

func validate_control(key_string: StringName, control_mode: ControlMode = ControlMode.just_pressed) -> bool:
	if (SGlobalConfig.is_initialized):
		match control_mode:
			ControlMode.just_pressed:
				return Input.is_action_just_pressed(key_string)
			ControlMode.pressed:
				return Input.is_action_pressed(key_string)
			ControlMode.just_release:
				return Input.is_action_just_released(key_string)
	return false

#region 是否监听向量
func try_input_vector() -> Dictionary:
	if (SGlobalConfig.is_initialized):
		match award_mode:
			"横版":
				return SMainController._vec_input_2_toward()
			"四向":
				return SMainController._vec_input_4_toward()
			"八向":
				return SMainController._vec_input_8_toward()
			"全向":
				return SMainController._vec_input_a_toward()
			_:
				push_error("输入有问题")
	return {}

func _try_vector_control() -> Vector2:
	if (SGlobalConfig.is_initialized):
		var input_move_info: Dictionary = try_input_vector()
		var input_move_vector: Vector2 = input_move_info["vec"] as Vector2
		return input_move_vector
	else:
		return Vector2.ZERO
#endregion

#region 测试用触发功能
func _try_save_game():
	if (Input.is_action_just_pressed("test_saving")):
		SLoadAndSave.emit_signal("saving_started")
		print("文件已经完成存储")
#endregion

#region 固定触发逻辑
## 玩家Ui触发: 在input组件内设计了Ui触发的逻辑，只允许在gaming_normal的阶段运行
func _avaliable_in_gaming():
	
	input_vector_dict.move = _try_vector_control()
	
	#weapon_texture.rotation = (Vector2.ZERO).direction_to(aim_texture.position).normalized().angle()
	
	if validate_control("brain_trigger", ControlMode.just_pressed):
		SUiSpawner._spawn_ui(brain_ui)
	elif validate_control("pause_game", ControlMode.just_pressed):
		SUiSpawner._spawn_ui(pause_ui)
	elif validate_control("interact", ControlMode.just_pressed):
		if interact_obj != null:
			interact_obj.interact_activated.emit(component_owner)
	
	for i in reactor_extension:
		i._listen()
	
	 
		
#endregion

func _validate_property(property: Dictionary) -> void:
	if disable_flag & 0b010 != 0:
		if property.name == "brain_ui" or property.name == "pause_ui":
			property.usage = PROPERTY_USAGE_NO_EDITOR
	if disable_flag & 0b001 != 0:
		if property.name == "award_mode":
			property.usage = PROPERTY_USAGE_NO_EDITOR
