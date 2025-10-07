## 输入响应组件 - 处理实体的输入控制逻辑
## 与InputListener组件配合使用，只在正常游戏状态下处理输入
@tool
class_name CInputReactor
extends IComponent

var reactor_extensions: Dictionary[ReactorExtension.REType, ReactorExtension] = {}

func _enter_tree() -> void:
	component_name = ComponentName.C_INPUT_REACTOR

func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)
	
	if component_owner in SMainController.player_static.values():
		SMainController.create_listener_by_player(component_owner, self)
	
	for i in get_children():
		if i is ReactorExtension:
			reactor_extensions.set(i.extention_type, i)
			i.c_input_reactor = self
	
	initialize_completed.emit()

func _late_initialize():
	for i in reactor_extensions.values():
		i._late_initialize()

func get_other_extension(type: ReactorExtension.REType) -> ReactorExtension:
	return reactor_extensions.get(type, null)

func validate_control(basic_key: StringName, control_mode: SoraConstant.InputType = SoraConstant.InputType.JUST_PRESSED, is_common: bool = false) -> bool:
	if (SGlobalConfig.is_initialized):
		if is_common:
			return SGlobalConfig.is_action_triggered(SoraConstant.InputTarget.COMMON, basic_key, control_mode)
		else:
			return SGlobalConfig.is_action_triggered(SMainController.get_input_target(component_owner), basic_key, control_mode)
	return false

#region 游戏内输入处理
func _avaliable_in_gaming():
	for extension in reactor_extensions.values():
		if !extension.disabled:
			extension._listen()
#endregion
