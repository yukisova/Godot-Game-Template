extends ISystem

signal preloading_started(_loading_setting: Dictionary)
signal presaving_started(_changed_config: Dictionary)

const CONFIG_PATH := "user://config.sav"

static var is_initialized = false
@export var use_default_config: bool


func _enter_tree() -> void:
	preloading_started.connect(_config_info_parser)
	presaving_started.connect(_config_changed)
	
	var config = _config_return()
	
	preloading_started.emit.call_deferred(config)

func _setup():
	pass

func _resetup():
	pass

#region 键位绑定管理
func update_action(action_name: String, input_config):
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
		print("配置系统: 创建新的输入动作 -> ", action_name)
	
	InputMap.action_erase_events(action_name)
	
	var input_event = _create_input_event(input_config)
	
	if input_event == null:
		push_warning("配置系统: 无法创建输入事件 -> ", action_name, " = ", input_config)
		return
	
	InputMap.action_add_event(action_name, input_event)
	
	var input_desc = _get_input_description(input_config)
	print("配置系统: 设置按键绑定 -> ", action_name, " = ", input_desc)

func rebind_action(action_name: String, new_input):
	update_action(action_name, new_input)

func _create_input_event(input_config) -> InputEvent:
	if input_config is int:
		var input_event = InputEventKey.new()
		input_event.keycode = input_config
		return input_event
	
	if input_config is Dictionary:
		var input_type = input_config.get("type", "key")
		
		match input_type:
			"key":
				var input_event = InputEventKey.new()
				input_event.keycode = input_config.get("keycode", KEY_NONE)
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
	
	if input_config is String:
		return _parse_input_string(input_config)
	
	push_warning("配置系统: 无法识别的输入配置格式 -> ", input_config)
	return null

func _parse_input_string(input_string: String) -> InputEvent:
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
			
			input_event.keycode = _parse_key_name(key_name)
			if input_event.keycode == KEY_NONE:
				push_warning("配置系统: 不支持的按键名称 -> ", key_name)
				return null
			
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

func _parse_key_name(key_name: String) -> Key:
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

func _get_input_description(input_config) -> String:
	if input_config is int:
		return OS.get_keycode_string(input_config)
	
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

func _get_mouse_button_name(button_index: MouseButton) -> String:
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

func create_mouse_config(button: MouseButton, ctrl: bool = false, alt: bool = false, shift: bool = false) -> Dictionary:
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

func create_key_config(keycode: Key, ctrl: bool = false, alt: bool = false, shift: bool = false) -> Dictionary:
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

func get_action_inputs(action_name: String) -> Array[String]:
	var descriptions: Array[String] = []
	
	if not InputMap.has_action(action_name):
		return descriptions
	
	var events = InputMap.action_get_events(action_name)
	for event in events:
		var desc = ""
		var modifiers: Array[String] = []
		
		if event.ctrl_pressed:
			modifiers.append("Ctrl")
		if event.alt_pressed:
			modifiers.append("Alt")
		if event.shift_pressed:
			modifiers.append("Shift")
		
		var modifier_str = ""
		if modifiers.size() > 0:
			modifier_str = "+".join(modifiers) + "+"
		
		if event is InputEventKey:
			desc = modifier_str + OS.get_keycode_string(event.keycode)
		elif event is InputEventMouseButton:
			var button_name = _get_mouse_button_name(event.button_index)
			desc = modifier_str + "Mouse:" + button_name
		else:
			desc = modifier_str + "未知输入"
		
		descriptions.append(desc)
	
	return descriptions

func set_multiple_bindings(bindings: Dictionary):
	print("配置系统: 开始批量设置键位绑定，共 ", bindings.size(), " 个")
	
	for action_name in bindings.keys():
		var input_config = bindings[action_name]
		update_action(action_name, input_config)
	
	print("配置系统: 批量键位绑定完成")

func reset_action_to_default(action_name: String):
	var default_keymap = SoraConstant.BASIC_SETTING.get("keymap", {}) as Dictionary
	
	if default_keymap.has(action_name):
		var default_config = default_keymap[action_name]
		update_action(action_name, default_config)
		print("配置系统: 重置动作到默认配置 -> ", action_name)
	else:
		push_warning("配置系统: 默认配置中未找到动作 -> ", action_name)


func is_action_triggered(input_target: SoraConstant.InputTarget, action_name: String, action_type: SoraConstant.InputType) -> bool:
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
		SoraConstant.InputTarget.PLAYER3:
			var fixed_action_name = "player3_" + action_name
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
		SoraConstant.InputTarget.PLAYER4:
			var fixed_action_name = "player4_" + action_name
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



func export_current_keymap() -> Dictionary:
	var keymap = {}
	var actions = InputMap.get_actions()
	
	for action in actions:
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			var event = events[0]
			
			if event is InputEventKey:
				if not event.ctrl_pressed and not event.alt_pressed and not event.shift_pressed:
					keymap[action] = event.keycode
				else:
					keymap[action] = create_key_config(event.keycode, event.ctrl_pressed, event.alt_pressed, event.shift_pressed)
			
			elif event is InputEventMouseButton:
				keymap[action] = create_mouse_config(event.button_index, event.ctrl_pressed, event.alt_pressed, event.shift_pressed)
	
	return keymap
#endregion

func _config_return() -> Dictionary:
	var configfile := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	var config: Dictionary
	
	if not configfile or use_default_config:
		config = SoraConstant.BASIC_SETTING
		print("配置系统: 使用默认配置")
	else:
		var json_for_setting := configfile.get_as_text()
		config = JSON.parse_string(json_for_setting) as Dictionary
		
		if config == null:
			config = SoraConstant.BASIC_SETTING
			push_warning("配置系统: 配置文件解析失败，使用默认配置")
		else:
			print("配置系统: 成功加载用户配置")
		
		configfile.close()
	
	return config

func _config_info_parser(_setting: Dictionary):
	print("配置系统: 开始解析配置数据")
	
	var keymap = _setting.get("keymap", {}) as Dictionary
	var _display = _setting.get("display", {}) as Dictionary
	
	print("配置系统: 找到 ", keymap.size(), " 个键位集合")
	
	for keymap_id in keymap.keys():
		var bindings = keymap[keymap_id] as Dictionary
		print("配置系统: 处理键位集合 ", keymap_id, " - ", bindings.size(), " 个绑定")
		
		# 根据键位集合ID确定前缀
		var prefix = ""
		match keymap_id:
			SoraConstant.InputTarget.COMMON:
				prefix = "common_"
			SoraConstant.InputTarget.PLAYER1:
				prefix = "player1_"
			SoraConstant.InputTarget.PLAYER2:
				prefix = "player2_"
			SoraConstant.InputTarget.PLAYER3:
				prefix = "player3_"
			SoraConstant.InputTarget.PLAYER4:
				prefix = "player4_"
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

func _config_changed(_changed_config: Dictionary):
	var configfile := FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	if not configfile:
		push_error("配置系统: 无法打开配置文件进行写入")
		return
	
	var jsoninfo = JSON.stringify(_changed_config)
	
	# 保存到文件
	configfile.store_string(jsoninfo)
	configfile.close()
	
	print("配置系统: 配置已保存到文件")
