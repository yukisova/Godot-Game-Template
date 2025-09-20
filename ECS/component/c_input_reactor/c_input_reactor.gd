## 输入响应组件 - 处理实体的输入控制逻辑
## 支持多种移动模式和输入控制方式，可扩展的输入响应系统
## 主要用于玩家角色控制，支持交互对象管理
## [br][b]编辑者:[/b] Sora
@tool
class_name CInputReactor
extends IComponent


## 移动方向模式
## 支持不同的移动控制方式
@export_enum("横版", "四向", "八向", "全向", "鼠标") var award_mode: String = "四向"

## 功能禁用标志位
## 控制组件的特定功能开关
@export_flags("向量监听") var disable_flag: int:
	set(v):
		disable_flag = v
		notify_property_list_changed()

## 输入向量字典
## 存储不同类型的输入向量
var input_vector_dict: Dictionary[String, Vector2] = {
	"move" : Vector2.ZERO,
	"toward" : Vector2.ZERO
}

## 输入响应扩展组件数组
## 扩展输入功能的组件列表
var reactor_extension: Array[ReactorExtension] = []

## 当前可交互对象
## 实体接近时设置的交互对象
var interact_obj: Interaction = null:
	set(v):
		if v == null:
			print("可交互对象重置")
		else:
			print("可交互对象更新: ", v.binding_entity.name)
		interact_obj = v

func _enter_tree() -> void:
	component_name = ComponentName.C_INPUT_REACTOR

func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)
	
	if component_owner in SMainController.player_static.values():
		SMainController.create_listener_by_player(component_owner, self)
	
	for i in get_children():
		if i is ReactorExtension:
			reactor_extension.append(i)
			i.c_input_reactor = self
	
	initialize_complete.emit()

func _late_initialize():
	for i in reactor_extension:
		i._late_initialize()

## 验证控制输入
## 
## 检查指定的输入动作是否满足特定的控制模式条件。
## [param key_string]: 输入动作名称，必须在输入映射中定义
## [param control_mode]: 控制模式，参见 [enum ControlMode]
## [br][br][b]返回:[/b] [bool] 该输入是否满足指定的控制模式
func validate_control(basic_key: StringName, control_mode: SoraConstant.InputType = SoraConstant.InputType.JUST_PRESSED, is_common: bool = false) -> bool:
	if (SGlobalConfig.is_initialized):
		if is_common:
			return SGlobalConfig.is_action_triggered(SoraConstant.InputTarget.COMMON, basic_key, control_mode)
		else:
			return SGlobalConfig.is_action_triggered(SMainController.get_input_target(component_owner), basic_key, control_mode)
	return false

#region 输入向量处理
## 尝试获取输入向量信息
## 
## 根据当前设置的移动模式返回对应的输入向量数据。
## [br][br][b]返回:[/b] [Dictionary] 包含向量信息的字典，包含"vec"和可能的"pre_vec"键
func try_input_vector() -> Dictionary:
	var entity_input_target: SoraConstant.InputTarget = SMainController.get_input_target(component_owner)
	if (SGlobalConfig.is_initialized):
		match award_mode:
			"横版":
				return SMainController._vec_input_2_toward(entity_input_target)
			"四向":
				return SMainController._vec_input_4_toward(entity_input_target)
			"八向":
				return SMainController._vec_input_8_toward(entity_input_target)
			"全向":
				return SMainController._vec_input_a_toward(entity_input_target)
			"鼠标":
				return SMainController._vec_input_m_toward(entity_input_target)
			_:
				push_error("输入模式配置错误: " + award_mode)
	return {}

## 获取向量控制输入
## 
## 内部调用 [method try_input_vector] 并提取移动向量。
## [br][br][b]返回:[/b] [Vector2] 当前帧的移动向量
func _try_vector_control() -> Dictionary:
	if (SGlobalConfig.is_initialized):
		var input_move_info: Dictionary = try_input_vector()
		return input_move_info
	else:
		return {}
#endregion

#region 测试功能
## 测试用存档功能
## 当按下测试存档键时触发存档操作
func _try_save_game():
	if (Input.is_action_just_pressed("test_saving")):
		SLoadAndSave.emit_signal("saving_started")
		print("文件已经完成存储")
#endregion

#region 游戏内输入处理
## 游戏状态下的输入处理
## 处理移动输入和交互输入，只在gaming_normal阶段运行
## 同时调用所有扩展组件的监听功能
func _avaliable_in_gaming():
	# 更新移动向量
	var input_vector_dict_update: Dictionary = _try_vector_control()
	var current_move = input_vector_dict_update.get("vec", Vector2.ZERO) as Vector2

	input_vector_dict.move = lerp(input_vector_dict.move, current_move, 0.3)
	if input_vector_dict_update.has("pre_vec"):
		var current_toward = input_vector_dict_update.get("pre_vec", Vector2.ZERO) as Vector2
		input_vector_dict.toward = lerp(input_vector_dict.toward, current_toward, 0.3)
	if validate_control("interact", SoraConstant.InputType.JUST_PRESSED):
		if interact_obj != null:
			interact_obj.interact_activated.emit(component_owner)
	
	# 调用扩展组件的监听功能
	for extension in reactor_extension:
		if !extension.disabled:
			extension._listen()
#endregion

func _validate_property(property: Dictionary) -> void:
	if disable_flag & 0b001 != 0:
		if property.name == "award_mode":
			property.usage = PROPERTY_USAGE_NO_EDITOR
