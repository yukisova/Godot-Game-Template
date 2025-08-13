## @editing: Sora [br]
## @describe: 输入响应组件 - 处理实体的输入控制逻辑
## 
## 该组件允许实体响应用户输入，支持多种移动模式和输入控制方式。
## 主要用于玩家角色的控制，也可用于其他需要输入响应的实体。
## 
## 功能特性：
## - 支持多种移动模式：横版、四向、八向、全向移动
## - 可扩展的输入响应系统（通过ReactorExtension）
## - 交互对象管理
## - 输入状态检测（按下、持续按住、释放）
@tool
class_name CInputReactor
extends IComponent

## 输入控制模式枚举
## 用于判断按键的不同触发状态
enum ControlMode{ 
	just_pressed = 0,  ## 刚按下
	pressed,           ## 持续按住
	just_release       ## 刚释放
}

## 移动方向模式
## 支持横版（左右）、四向、八向、全向移动
@export_enum("横版", "四向", "八向", "全向") var award_mode: String = "四向"

## 功能禁用标志位
## 位0: 向量监听禁用
## 位1: 主控禁用
@export_flags("向量监听","主控") var disable_flag: int:
	set(v):
		disable_flag = v
		notify_property_list_changed()

## 输入向量字典
## 存储不同类型的输入向量，如移动向量等
var input_vector_dict: Dictionary[String, Vector2] = {
	"move" : Vector2.ZERO
}

## 输入响应扩展组件数组
## 用于扩展输入功能，如UI触发、特殊操作等
var reactor_extension: Array[ReactorExtension] = []

## 当前可交互对象
## 当实体接近可交互对象时设置，离开时清空
var interact_obj: PassiveInteraction = null:
	set(v):
		if v == null:
			print("可交互对象重置")
		else:
			print("可交互对象更新: ", v.binding.component_owner.name)
		interact_obj = v

func _enter_tree() -> void:
	component_name = ComponentName.c_input_reactor

func _initialize(_owner: IEntity):
	super._initialize(_owner)
	
	if component_owner == SMainController.player_static:
		SMainController.input_listener.binding_input_component = self
		disable_flag |= 0b010
	
	for i in get_children():
		if i is ReactorExtension:
			reactor_extension.append(i)
			i.c_input_reactor = self
			

## 验证控制输入
## @param key_string: 输入动作名称
## @param control_mode: 控制模式（刚按下/持续按住/刚释放）
## @return: 返回该输入是否满足指定的控制模式
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

#region 输入向量处理
## 尝试获取输入向量信息
## 根据当前设置的移动模式返回对应的输入向量数据
## @return: 包含向量信息的字典，包含"vec"和可能的"pre_vec"
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
				push_error("输入模式配置错误: " + award_mode)
	return {}

## 获取向量控制输入
## 内部调用try_input_vector()并提取移动向量
## @return: 当前帧的移动向量
func _try_vector_control() -> Vector2:
	if (SGlobalConfig.is_initialized):
		var input_move_info: Dictionary = try_input_vector()
		var input_move_vector: Vector2 = input_move_info.get("vec", Vector2.ZERO) as Vector2
		return input_move_vector
	else:
		return Vector2.ZERO
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
	input_vector_dict.move = _try_vector_control()

	# 处理交互输入
	if validate_control("interact", ControlMode.just_pressed):
		if interact_obj != null:
			interact_obj.interact_activated.emit(component_owner)
	
	# 调用扩展组件的监听功能
	for extension in reactor_extension:
		extension._listen()
#endregion

func _validate_property(property: Dictionary) -> void:
	if disable_flag & 0b010 != 0:
		if property.name == "brain_ui" or property.name == "pause_ui":
			property.usage = PROPERTY_USAGE_NO_EDITOR
	if disable_flag & 0b001 != 0:
		if property.name == "award_mode":
			property.usage = PROPERTY_USAGE_NO_EDITOR
