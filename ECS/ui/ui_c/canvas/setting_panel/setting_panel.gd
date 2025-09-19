## @editing: Sora [br]
## @describe: 游戏设置面板 - 综合性的游戏配置界面
##
## 该面板提供了游戏的各种设置选项：
## - 键位映射的自定义配置（支持键盘和鼠标）
## - 音频音量的调节控制
## - 显示模式和语言切换
## - 配置的保存和重置功能
##
## 主要功能：
## - 实时键位重映射系统（键盘+鼠标+修饰键）
## - 音频总线音量控制
## - 窗口模式切换（窗口化/全屏）
## - 多语言支持和切换
## - 配置冲突检测和验证
##
## 技术特性：
## - 动态UI生成（键位列表）
## - 实时输入捕获和处理（键盘/鼠标/修饰键）
## - 配置数据的深度复制
## - 信号驱动的设置同步
## - 多格式输入配置支持
##
## 输入配置支持：
## - 简单键码格式（兼容旧版本）
## - 字典格式（支持修饰键和鼠标）
## - 字符串格式（人性化配置）
##
## 使用场景：
## - 游戏主菜单的设置选项
## - 游戏内暂停菜单的设置
## - 首次运行的配置向导
extends CreationCanvas

#region UI容器组件

@export_group("容器")

## 键位映射容器
## 动态生成键位设置项的容器
@export var keymap_container: VBoxContainer

## 显示设置容器
## 包含窗口模式和语言设置的容器
@export var display_setting: VBoxContainer

## 音频设置容器
## 包含各音频总线音量控制的容器
@export var audio_setting: VBoxContainer

#endregion

#region 音频控制组件

@export_group("控件_音频")

## 主音量滑块
## 控制游戏整体音量的滑块控件
@export var audio_setting_master: HSlider

## 音效音量滑块
## 控制音效音量的滑块控件
@export var audio_setting_sfx: HSlider

## 背景音乐音量滑块
## 控制背景音乐音量的滑块控件
@export var audio_setting_bgm: HSlider

#endregion

#region 显示控制组件

@export_group("控件_显示")

@export_subgroup("窗口", "window_")

## 窗口化模式按钮
## 切换到窗口化显示模式
@export var window_windowed: Button

## 全屏模式按钮
## 切换到全屏显示模式
@export var window_fullscreen: Button

@export_subgroup("多语言", "translation_")

## 英语按钮
## 切换游戏语言为英语
@export var translation_english: Button

## 中文按钮
## 切换游戏语言为中文
@export var translation_chinese: Button

#endregion

#region 操作控制组件

@export_group("控件_保存")

## 确认保存按钮
## 应用并保存当前设置
@export var confirm: FuncButton

## 重置按钮
## 重置所有设置为默认值
@export var reset: FuncButton

#endregion

#region 设置数据管理

## 当前配置字典
## 存储用户当前的所有设置项
var current_config: Dictionary

## 当前活动设置
## 临时存储正在修改的设置项（主要用于键位设置）
var current_setting: Dictionary = {}

#endregion

func _enter_tree() -> void:
	confirm.pressed.connect(Callable(func(_args):
		SGlobalConfig.presaving_started.emit(current_config)
		window_closed.emit()
		).bind(confirm.args)
	)
	reset.pressed.connect(Callable(func(_args):
		SGlobalConfig._resetup()
		).bind(reset.args)
	)
	current_config = SGlobalConfig._config_return()
	current_config = current_config.duplicate(true)

func _ready() -> void:
	__init_audio()
	__init_display()
	__init_keymap()


func _unhandled_input(event: InputEvent) -> void:
	if !current_setting.is_empty():
		if current_setting.has("keymap"):
			var input_config = null
			var is_valid_input = false
			
			# 检测键盘输入
			if event is InputEventKey and event.is_pressed():
				input_config = _create_input_config_from_event(event)
				is_valid_input = true
			
			# 检测鼠标输入  
			elif event is InputEventMouseButton and event.is_pressed():
				input_config = _create_input_config_from_event(event)
				is_valid_input = true
			
			if is_valid_input and input_config != null:
				var target_action = current_setting["keymap"]["name"]
				var target = current_setting["keymap"]["target"]
				
				if __input_unique_check(target_action, input_config):
					current_config["keymap"][target_action] = input_config
					
					# 更新显示文本
					var display_text = _get_input_config_display_text(input_config)
					target.get_child(0).text = display_text
					
					print("设置面板: 成功绑定 ", target_action, " -> ", display_text)
				else:
					print("按键映射出现冲突！！！")
				
				current_setting.clear()
				target.set_pressed_no_signal(false)

#region 音频设置
func __init_audio():
	var _audio = current_config["audio"]
	audio_setting_master.drag_ended.connect(func(is_changed: bool):
		if is_changed:
			SAudioMaster._set_volume(SAudioMaster.AudioBusEnum.MASTER, audio_setting_master.value)
		)
	audio_setting_bgm.drag_ended.connect(func(is_changed: bool):
		if is_changed:
			SAudioMaster._set_volume(SAudioMaster.AudioBusEnum.MUSIC, audio_setting_bgm.value)
		)
	audio_setting_sfx.drag_ended.connect(func(is_changed: bool):
		if is_changed:
			SAudioMaster._set_volume(SAudioMaster.AudioBusEnum.SFX, audio_setting_sfx.value)
		)
#endregion

#region 显示设置
func __init_display():
	var _display = current_config["display"]
	

	window_windowed.pressed.connect(func():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		)
	window_fullscreen.pressed.connect(func():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	)
	
	translation_english.pressed.connect(func():
		TranslationServer.set_locale("en")
		)
	translation_chinese.pressed.connect(func():
		TranslationServer.set_locale("zh_CN"))


func __window_setting_id_to_string(display_window):
	match display_window:
		SoraConstant.WINDOWED:
			return "窗口化"
		SoraConstant.FULLSCREEN:
			return "全屏"
func __definition_setting_id_to_string(display_definition):
	match display_definition:
		SoraConstant.HD:
			return "1280*720"
		SoraConstant.SHD:
			return "1920*1080"
#endregion

#region 键盘键位设置
func __init_keymap():
	var keymap_info_prototype = get_node("%KeymapInfo") as Button
	
	var keymap = current_config["keymap"]
	for action_name in keymap.keys():
		var keymap_record = keymap_info_prototype.duplicate() as Button
		keymap_info_prototype.get_parent().add_child(keymap_record)
		keymap_record.text = action_name
		
		# 根据不同的配置格式显示对应的文本
		var input_config = keymap[action_name]
		var display_text = _get_input_config_display_text(input_config)
		keymap_record.get_child(0).text = display_text
		keymap_record.show()
		
		keymap_record.toggled.connect(Callable(func (toggled:bool,_action_name: String, _keymap_record:Button):
			if toggled:
				current_setting["keymap"] = {
					"name" = _action_name,
					"target" = _keymap_record
			}
			else:
				current_setting.clear()
			).bind(keymap_record.text, keymap_record as Button)
		)

## 输入配置唯一性检查
## 检查新的输入配置是否与现有配置冲突
## @param target_action: 目标动作名称
## @param new_input_config: 新的输入配置
## @return: 是否通过唯一性检查
func __input_unique_check(target_action: String, new_input_config) -> bool:
	var flag: bool = true
	for action_name in current_config["keymap"].keys():
		if target_action == action_name:
			continue
		
		var existing_config = current_config["keymap"][action_name]
		if _input_configs_equal(new_input_config, existing_config):
			flag = false
			break
	return flag

## 比较两个输入配置是否相等
## @param config1: 第一个配置
## @param config2: 第二个配置
## @return: 是否相等
func _input_configs_equal(config1, config2) -> bool:
	# 如果都是简单的键码
	if config1 is int and config2 is int:
		return config1 == config2
	
	# 如果一个是键码，一个是字典（键盘配置）
	if config1 is int and config2 is Dictionary:
		if config2.get("type", "key") == "key" and config2.get("keycode") == config1:
			# 检查是否有修饰键
			return not (config2.get("ctrl", false) or config2.get("alt", false) or config2.get("shift", false))
		return false
	
	if config2 is int and config1 is Dictionary:
		if config1.get("type", "key") == "key" and config1.get("keycode") == config2:
			# 检查是否有修饰键
			return not (config1.get("ctrl", false) or config1.get("alt", false) or config1.get("shift", false))
		return false
	
	# 如果都是字典
	if config1 is Dictionary and config2 is Dictionary:
		var type1 = config1.get("type", "key")
		var type2 = config2.get("type", "key")
		
		if type1 != type2:
			return false
		
		if type1 == "key":
			return (config1.get("keycode") == config2.get("keycode") and
					config1.get("ctrl", false) == config2.get("ctrl", false) and
					config1.get("alt", false) == config2.get("alt", false) and
					config1.get("shift", false) == config2.get("shift", false))
		
		elif type1 == "mouse":
			return (config1.get("button") == config2.get("button") and
					config1.get("ctrl", false) == config2.get("ctrl", false) and
					config1.get("alt", false) == config2.get("alt", false) and
					config1.get("shift", false) == config2.get("shift", false))
	
	# 如果都是字符串
	if config1 is String and config2 is String:
		return config1 == config2
	
	return false

## 从输入事件创建输入配置
## @param event: 输入事件
## @return: 输入配置
func _create_input_config_from_event(event: InputEvent):
	if event is InputEventKey:
		# 如果没有修饰键，使用简单格式保持兼容性
		if not event.ctrl_pressed and not event.alt_pressed and not event.shift_pressed:
			return event.keycode
		else:
			# 使用字典格式支持修饰键
			var config = {
				"type": "key",
				"keycode": event.keycode
			}
			if event.ctrl_pressed:
				config["ctrl"] = true
			if event.alt_pressed:
				config["alt"] = true
			if event.shift_pressed:
				config["shift"] = true
			return config
	
	elif event is InputEventMouseButton:
		# 鼠标事件总是使用字典格式
		var config = {
			"type": "mouse",
			"button": event.button_index
		}
		if event.ctrl_pressed:
			config["ctrl"] = true
		if event.alt_pressed:
			config["alt"] = true
		if event.shift_pressed:
			config["shift"] = true
		return config
	
	return null

## 获取输入配置的显示文本
## @param input_config: 输入配置
## @return: 显示文本
func _get_input_config_display_text(input_config) -> String:
	# 如果是简单的键码
	if input_config is int:
		return "KEY_" + OS.get_keycode_string(input_config)
	
	# 如果是字典格式
	if input_config is Dictionary:
		var input_type = input_config.get("type", "key")
		var modifiers = []
		
		if input_config.get("ctrl", false):
			modifiers.append("Ctrl")
		if input_config.get("alt", false):
			modifiers.append("Alt")
		if input_config.get("shift", false):
			modifiers.append("Shift")
		
		var modifier_str = ""
		if modifiers.size() > 0:
			modifier_str = "+".join(modifiers) + "+"
		
		match input_type:
			"key":
				var keycode = input_config.get("keycode", KEY_NONE)
				return modifier_str + "KEY_" + OS.get_keycode_string(keycode)
			"mouse":
				var button = input_config.get("button", MOUSE_BUTTON_LEFT)
				var button_name = _get_mouse_button_display_name(button)
				return modifier_str + "MOUSE_" + button_name
			_:
				return "未知输入"
	
	# 如果是字符串格式
	if input_config is String:
		return input_config.to_upper()
	
	return str(input_config)

## 获取鼠标按钮的显示名称
## @param button_index: 鼠标按钮索引
## @return: 显示名称
func _get_mouse_button_display_name(button_index: MouseButton) -> String:
	match button_index:
		MOUSE_BUTTON_LEFT:
			return "LEFT"
		MOUSE_BUTTON_RIGHT:
			return "RIGHT"
		MOUSE_BUTTON_MIDDLE:
			return "MIDDLE"
		MOUSE_BUTTON_WHEEL_UP:
			return "WHEEL_UP"
		MOUSE_BUTTON_WHEEL_DOWN:
			return "WHEEL_DOWN"
		_:
			return "BUTTON" + str(button_index)
#endregion
