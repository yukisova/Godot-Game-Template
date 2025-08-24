## 全局配置系统 - 管理游戏设置的预加载和持久化存储
## 专门负责游戏设置的管理，包括键位绑定、显示设置、音频设置等
## 核心功能：设置预加载、键位管理、配置持久化、默认配置、热更新
## 配置类型：键位映射、显示设置、音频设置、游戏设置
## [br][b]编辑者:[/b] Sora
extends ISystem

## 配置预加载开始信号，当开始加载用户配置时发出
## [param _loading_setting]: 加载的配置数据，类型为 [Dictionary]
signal preloading_started(_loading_setting: Dictionary)

## 配置保存开始信号，当用户更改配置需要保存时发出
## [param _changed_config]: 更改的配置数据，类型为 [Dictionary]
signal presaving_started(_changed_config: Dictionary)

## 使用默认配置标志，为true时忽略用户配置文件，强制使用默认设置
@export var use_default_config: bool

## 配置文件路径，用户配置文件的存储位置
const CONFIG_PATH := "user://config.sav"

## 初始化状态标志，标记配置系统是否已完成初始化
static var is_initialized = false

## 系统初始化，连接配置信号并立即加载用户配置
func _enter_tree() -> void:
	# 连接配置处理信号
	preloading_started.connect(_config_info_parser)
	presaving_started.connect(_config_changed)
	
	# 立即加载配置文件
	var config = _config_return()
	
	preloading_started.emit.call_deferred(config)

## 系统设置，配置系统的基础设置（预留接口）
func _setup():
	# 预留给将来的配置系统扩展
	pass

## 系统重置，配置系统重置逻辑（当前无需特殊处理）
func _resetup():
	# 配置信息通常不需要在游戏重置时清理
	pass

#region 键位绑定管理
## 更新动作映射，为指定动作设置新的按键绑定，支持键盘和鼠标按键
## [param action_name]: 动作名称
## [param input_config]: 输入配置（可以是键码或配置字典）
static func update_action(action_name: String, input_config):
	# 确保动作存在于输入映射中
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
		print("配置系统: 创建新的输入动作 -> ", action_name)
	
	# 清除现有的按键绑定
	InputMap.action_erase_events(action_name)
	
	# 创建输入事件
	var input_event = _create_input_event(input_config)
	
	if input_event == null:
		push_warning("配置系统: 无法创建输入事件 -> ", action_name, " = ", input_config)
		return
	
	# 添加新的按键绑定
	InputMap.action_add_event(action_name, input_event)
	
	var input_desc = _get_input_description(input_config)
	print("配置系统: 设置按键绑定 -> ", action_name, " = ", input_desc)

## 重新绑定动作，为指定动作重新绑定按键（update_action的别名）
## [param action_name]: 动作名称
## [param new_input]: 新的输入配置
static func rebind_action(action_name: String, new_input):
	update_action(action_name, new_input)

## 创建输入事件，根据输入配置创建对应的输入事件对象
## [param input_config]: 输入配置（键码、配置字典等）
## [br][br][b]返回:[/b] InputEvent对象或null
static func _create_input_event(input_config) -> InputEvent:
	# 如果是简单的键码（兼容旧配置）
	if input_config is int:
		var input_event = InputEventKey.new()
		input_event.keycode = input_config
		return input_event
	
	# 如果是配置字典
	if input_config is Dictionary:
		var input_type = input_config.get("type", "key")
		
		match input_type:
			"key":
				var input_event = InputEventKey.new()
				input_event.keycode = input_config.get("keycode", KEY_NONE)
				# 支持修饰键
				if input_config.has("ctrl"):
					input_event.ctrl_pressed = input_config.get("ctrl", false)
				if input_config.has("alt"):
					input_event.alt_pressed = input_config.get("alt", false)
				if input_config.has("shift"):
					input_event.shift_pressed = input_config.get("shift", false)
				return input_event
			
			"mouse":
				var input_event = InputEventMouseButton.new()
				input_event.button_index = input_config.get("keycode", MOUSE_BUTTON_LEFT)
				# 支持修饰键
				if input_config.has("ctrl"):
					input_event.ctrl_pressed = input_config.get("ctrl", false)
				if input_config.has("alt"):
					input_event.alt_pressed = input_config.get("alt", false)
				if input_config.has("shift"):
					input_event.shift_pressed = input_config.get("shift", false)
				return input_event
			
			_:
				push_warning("配置系统: 不支持的输入类型 -> ", input_type)
				return null
	
	# 如果是字符串（支持特殊格式）
	if input_config is String:
		return _parse_input_string(input_config)
	
	push_warning("配置系统: 无法识别的输入配置格式 -> ", input_config)
	return null

## 解析输入字符串，解析特殊格式的输入字符串，例如"mouse:left", "key:space+ctrl"
## [param input_string]: 输入字符串
## [br][br][b]返回:[/b] InputEvent对象或null
static func _parse_input_string(input_string: String) -> InputEvent:
	var parts = input_string.split(":")
	if parts.size() != 2:
		push_warning("配置系统: 输入字符串格式错误 -> ", input_string)
		return null
	
	var input_type = parts[0].strip_edges()
	var input_value = parts[1].strip_edges()
	
	match input_type:
		"mouse":
			var input_event = InputEventMouseButton.new()
			var mouse_parts = input_value.split("+")
			var button_name = mouse_parts[0].strip_edges()
			
			# 解析鼠标按钮
			match button_name.to_lower():
				"left":
					input_event.button_index = MOUSE_BUTTON_LEFT
				"right":
					input_event.button_index = MOUSE_BUTTON_RIGHT
				"middle":
					input_event.button_index = MOUSE_BUTTON_MIDDLE
				"wheel_up":
					input_event.button_index = MOUSE_BUTTON_WHEEL_UP
				"wheel_down":
					input_event.button_index = MOUSE_BUTTON_WHEEL_DOWN
				_:
					push_warning("配置系统: 不支持的鼠标按钮 -> ", button_name)
					return null
			
			# 解析修饰键
			for i in range(1, mouse_parts.size()):
				var modifier = mouse_parts[i].strip_edges().to_lower()
				match modifier:
					"ctrl":
						input_event.ctrl_pressed = true
					"alt":
						input_event.alt_pressed = true
					"shift":
						input_event.shift_pressed = true
			
			return input_event
		
		"key":
			var input_event = InputEventKey.new()
			var key_parts = input_value.split("+")
			var key_name = key_parts[0].strip_edges()
			
			# 解析按键名称为键码
			input_event.keycode = _parse_key_name(key_name)
			if input_event.keycode == KEY_NONE:
				push_warning("配置系统: 不支持的按键名称 -> ", key_name)
				return null
			
			# 解析修饰键
			for i in range(1, key_parts.size()):
				var modifier = key_parts[i].strip_edges().to_lower()
				match modifier:
					"ctrl":
						input_event.ctrl_pressed = true
					"alt":
						input_event.alt_pressed = true
					"shift":
						input_event.shift_pressed = true
			
			return input_event
		
		_:
			push_warning("配置系统: 不支持的输入类型 -> ", input_type)
			return null

## 解析按键名称，将按键名称字符串转换为对应的键码
## [param key_name]: 按键名称
## [br][br][b]返回:[/b] Key键码
static func _parse_key_name(key_name: String) -> Key:
	match key_name.to_lower():
		"space":
			return KEY_SPACE
		"tab":
			return KEY_TAB
		"enter":
			return KEY_ENTER
		"escape", "esc":
			return KEY_ESCAPE
		"a":
			return KEY_A
		"b":
			return KEY_B
		"c":
			return KEY_C
		"d":
			return KEY_D
		"e":
			return KEY_E
		"f":
			return KEY_F
		"g":
			return KEY_G
		"h":
			return KEY_H
		"i":
			return KEY_I
		"j":
			return KEY_J
		"k":
			return KEY_K
		"l":
			return KEY_L
		"m":
			return KEY_M
		"n":
			return KEY_N
		"o":
			return KEY_O
		"p":
			return KEY_P
		"q":
			return KEY_Q
		"r":
			return KEY_R
		"s":
			return KEY_S
		"t":
			return KEY_T
		"u":
			return KEY_U
		"v":
			return KEY_V
		"w":
			return KEY_W
		"x":
			return KEY_X
		"y":
			return KEY_Y
		"z":
			return KEY_Z
		"f1":
			return KEY_F1
		"f2":
			return KEY_F2
		"f3":
			return KEY_F3
		"f4":
			return KEY_F4
		"f5":
			return KEY_F5
		"f6":
			return KEY_F6
		"f7":
			return KEY_F7
		"f8":
			return KEY_F8
		"f9":
			return KEY_F9
		"f10":
			return KEY_F10
		"f11":
			return KEY_F11
		"f12":
			return KEY_F12
		_:
			return KEY_NONE

## 获取输入描述，为输入配置生成可读的描述文本
## [param input_config]: 输入配置
## [br][br][b]返回:[/b] 描述字符串
static func _get_input_description(input_config) -> String:
	# 如果是简单的键码
	if input_config is int:
		return OS.get_keycode_string(input_config)
	
	# 如果是配置字典
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
				return modifier_str + OS.get_keycode_string(keycode)
			"mouse":
				var button = input_config.get("button", MOUSE_BUTTON_LEFT)
				var button_name = _get_mouse_button_name(button)
				return modifier_str + "Mouse:" + button_name
			_:
				return "未知输入类型"
	
	# 如果是字符串
	if input_config is String:
		return input_config
	
	return str(input_config)

## 获取鼠标按钮名称，将鼠标按钮索引转换为可读名称
## [param button_index]: 鼠标按钮索引，类型为 [MouseButton]
## [br][br][b]返回:[/b] 按钮名称
static func _get_mouse_button_name(button_index: MouseButton) -> String:
	match button_index:
		MOUSE_BUTTON_LEFT:
			return "左键"
		MOUSE_BUTTON_RIGHT:
			return "右键"
		MOUSE_BUTTON_MIDDLE:
			return "中键"
		MOUSE_BUTTON_WHEEL_UP:
			return "滚轮上"
		MOUSE_BUTTON_WHEEL_DOWN:
			return "滚轮下"
		_:
			return "按钮" + str(button_index)

## 创建鼠标按键配置，便捷方法：为鼠标按键创建配置字典
## [param button]: 鼠标按钮索引，类型为 [MouseButton]
## [param ctrl]: 是否需要Ctrl修饰键
## [param alt]: 是否需要Alt修饰键
## [param shift]: 是否需要Shift修饰键
## [br][br][b]返回:[/b] 配置字典
static func create_mouse_config(button: MouseButton, ctrl: bool = false, alt: bool = false, shift: bool = false) -> Dictionary:
	var config = {
		"type": "mouse",
		"button": button
	}
	
	if ctrl:
		config["ctrl"] = true
	if alt:
		config["alt"] = true
	if shift:
		config["shift"] = true
	
	return config

## 创建键盘按键配置，便捷方法：为键盘按键创建配置字典
## [param keycode]: 键码，类型为 [Key]
## [param ctrl]: 是否需要Ctrl修饰键
## [param alt]: 是否需要Alt修饰键
## [param shift]: 是否需要Shift修饰键
## [br][br][b]返回:[/b] 配置字典
static func create_key_config(keycode: Key, ctrl: bool = false, alt: bool = false, shift: bool = false) -> Dictionary:
	var config = {
		"type": "key",
		"keycode": keycode
	}
	
	if ctrl:
		config["ctrl"] = true
	if alt:
		config["alt"] = true
	if shift:
		config["shift"] = true
	
	return config

## 获取当前动作的输入配置，返回当前绑定到指定动作的输入事件信息
## [param action_name]: 动作名称
## [br][br][b]返回:[/b] 输入配置描述数组
static func get_action_inputs(action_name: String) -> Array[String]:
	var descriptions: Array[String] = []
	
	if not InputMap.has_action(action_name):
		return descriptions
	
	var events = InputMap.action_get_events(action_name)
	for event in events:
		var desc = ""
		var modifiers: Array[String] = []
		
		# 检查修饰键
		if event.ctrl_pressed:
			modifiers.append("Ctrl")
		if event.alt_pressed:
			modifiers.append("Alt")
		if event.shift_pressed:
			modifiers.append("Shift")
		
		var modifier_str = ""
		if modifiers.size() > 0:
			modifier_str = "+".join(modifiers) + "+"
		
		# 根据事件类型生成描述
		if event is InputEventKey:
			desc = modifier_str + OS.get_keycode_string(event.keycode)
		elif event is InputEventMouseButton:
			var button_name = _get_mouse_button_name(event.button_index)
			desc = modifier_str + "Mouse:" + button_name
		else:
			desc = modifier_str + "未知输入"
		
		descriptions.append(desc)
	
	return descriptions

## 批量设置键位绑定，便捷方法：一次性设置多个键位绑定
## [param bindings]: 键位绑定字典，格式为 {action_name: input_config}
static func set_multiple_bindings(bindings: Dictionary):
	print("配置系统: 开始批量设置键位绑定，共 ", bindings.size(), " 个")
	
	for action_name in bindings.keys():
		var input_config = bindings[action_name]
		update_action(action_name, input_config)
	
	print("配置系统: 批量键位绑定完成")

## 重置动作到默认配置，将指定动作重置为默认配置中的绑定
## [param action_name]: 动作名称
static func reset_action_to_default(action_name: String):
	var default_keymap = SoraConstant.BASIC_SETTING.get("keymap", {}) as Dictionary
	
	if default_keymap.has(action_name):
		var default_config = default_keymap[action_name]
		update_action(action_name, default_config)
		print("配置系统: 重置动作到默认配置 -> ", action_name)
	else:
		push_warning("配置系统: 默认配置中未找到动作 -> ", action_name)

# 使用SoraConstant中定义的枚举
# enum InputTarget -> SoraConstant.InputTarget 
# enum ListenType -> SoraConstant.InputType

## 检查是否触发指定动作，根据输入目标和输入类型检查动作是否被触发
## [param input_target]: 输入目标，类型为 [SoraConstant.InputTarget]
## [param action_name]: 动作名称
## [param action_type]: 输入类型，类型为 [SoraConstant.InputType]
## [br][br][b]返回:[/b] 是否触发
static func is_action_triggered(input_target: SoraConstant.InputTarget, action_name: String, action_type: SoraConstant.InputType) -> bool:
	match input_target:
		SoraConstant.InputTarget.COMMON:
			var fixed_action_name = "common_" + action_name
			match action_type:
				SoraConstant.InputType.JUST_PRESSED:
					return Input.is_action_just_pressed(fixed_action_name)
				SoraConstant.InputType.PRESSED:
					return Input.is_action_pressed(fixed_action_name)
				SoraConstant.InputType.JUST_RELEASED:
					return Input.is_action_just_released(fixed_action_name)
				_:
					push_warning("配置系统: 不支持的输入类型 -> ", action_type)
					return false
		SoraConstant.InputTarget.PLAYER1:
			var fixed_action_name = "player1_" + action_name
			match action_type:
				SoraConstant.InputType.JUST_PRESSED:
					return Input.is_action_just_pressed(fixed_action_name)
				SoraConstant.InputType.PRESSED:
					return Input.is_action_pressed(fixed_action_name)
				SoraConstant.InputType.JUST_RELEASED:
					return Input.is_action_just_released(fixed_action_name)
				_:
					push_warning("配置系统: 不支持的输入类型 -> ", action_type)
					return false
		SoraConstant.InputTarget.PLAYER2:
			var fixed_action_name = "player2_" + action_name
			match action_type:
				SoraConstant.InputType.JUST_PRESSED:
					return Input.is_action_just_pressed(fixed_action_name)
				SoraConstant.InputType.PRESSED:
					return Input.is_action_pressed(fixed_action_name)
				SoraConstant.InputType.JUST_RELEASED:
					return Input.is_action_just_released(fixed_action_name)
				_:
					push_warning("配置系统: 不支持的输入类型 -> ", action_type)
					return false
		_:
			push_warning("配置系统: 不支持的输入目标 -> ", input_target)
			return false



## 导出当前键位配置，返回当前所有键位绑定的配置字典，可用于保存到文件
## [br][br][b]返回:[/b] 键位配置字典
static func export_current_keymap() -> Dictionary:
	var keymap = {}
	var actions = InputMap.get_actions()
	
	for action in actions:
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			# 只导出第一个绑定事件（简化处理）
			var event = events[0]
			
			if event is InputEventKey:
				# 如果没有修饰键，使用简单格式
				if not event.ctrl_pressed and not event.alt_pressed and not event.shift_pressed:
					keymap[action] = event.keycode
				else:
					# 使用字典格式
					keymap[action] = create_key_config(event.keycode, event.ctrl_pressed, event.alt_pressed, event.shift_pressed)
			
			elif event is InputEventMouseButton:
				# 使用字典格式
				keymap[action] = create_mouse_config(event.button_index, event.ctrl_pressed, event.alt_pressed, event.shift_pressed)
	
	return keymap
#endregion

## 配置文件加载，从配置文件或默认设置中加载配置数据
## [br][br][b]返回:[/b] 配置数据字典
## [br][b]已知问题:[/b] 当前实现主要依赖SoraConstant中的默认设置，缺少完整的设置记录功能
func _config_return() -> Dictionary:
	var configfile := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	var config: Dictionary
	
	# 如果配置文件不存在或强制使用默认配置
	if not configfile or use_default_config:
		config = SoraConstant.BASIC_SETTING
		print("配置系统: 使用默认配置")
	else:
		# 从JSON文件解析配置
		var json_for_setting := configfile.get_as_text()
		config = JSON.parse_string(json_for_setting) as Dictionary
		
		if config == null:
			# JSON解析失败，回退到默认配置
			config = SoraConstant.BASIC_SETTING
			push_warning("配置系统: 配置文件解析失败，使用默认配置")
		else:
			print("配置系统: 成功加载用户配置")
		
		configfile.close()
	
	return config

## 配置信息解析，解析加载的配置并应用到游戏系统中
## [param _setting]: 配置数据字典
func _config_info_parser(_setting: Dictionary):
	print("配置系统: 开始解析配置数据")
	
	# 解析键位映射配置
	var keymap = _setting.get("keymap", {}) as Dictionary
	var _display = _setting.get("display", {}) as Dictionary
	
	print("配置系统: 找到 ", keymap.size(), " 个键位集合")
	
	# 应用分层键位绑定
	for keymap_id in keymap.keys():
		var bindings = keymap[keymap_id] as Dictionary
		print("配置系统: 处理键位集合 ", keymap_id, " - ", bindings.size(), " 个绑定")
		
		# 根据键位集合ID确定前缀
		var prefix = ""
		match keymap_id:
			0:
				prefix = "common_"
			1:
				prefix = "player1_"
			2:
				prefix = "player2_"
			_:
				push_warning("配置系统: 未知的键位集合ID -> ", keymap_id)
				continue
		
		# 应用该集合中的所有键位绑定
		for action_name in bindings.keys():
			var input_config = bindings[action_name]
			var full_action_name = prefix + action_name
			update_action(full_action_name, input_config)
	
	# TODO: 应用显示设置
	# 例如：分辨率、全屏模式、垂直同步等
	
	# TODO: 应用音频设置
	# 例如：主音量、音效音量、背景音乐音量等
	
	
	# 标记配置系统已初始化
	is_initialized = true
	print("配置系统: 配置解析完成，系统已初始化")

## 配置更改处理，将用户的配置更改保存到文件
## [param _changed_config]: 更改的配置数据字典
func _config_changed(_changed_config: Dictionary):
	var configfile := FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	if not configfile:
		push_error("配置系统: 无法打开配置文件进行写入")
		return
	
	# 将配置数据序列化为JSON
	var jsoninfo = JSON.stringify(_changed_config)
	
	# 保存到文件
	configfile.store_string(jsoninfo)
	configfile.close()
	
	print("配置系统: 配置已保存到文件")
