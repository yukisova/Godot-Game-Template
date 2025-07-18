## 游戏设置系统: 与存档系统类似，但是设置信息是预加载的
class_name S_GlobalConfig
extends ISystem

## 此处会将游戏的内容
signal preloading_started(_loading_setting: Dictionary)
signal presaving_started(_changed_config: Dictionary)

@export var use_default_config: bool

const CONFIG_PATH := "user://config.sav"

static var is_initialized = false

func _enter_tree() -> void:
	Main.s_global_config = self

	preloading_started.connect(_config_info_parser)
	presaving_started.connect(_config_changed)
	
	var config = _config_return()
	preloading_started.emit.call_deferred(config)

#region 键位设置
static func update_action(action_name: String, key):
	if (!InputMap.has_action(action_name)):
		InputMap.add_action(action_name)
	InputMap.action_erase_events(action_name)
	var input_event = InputEventKey.new()
	input_event.keycode = key;
	InputMap.action_add_event(action_name, input_event)

static func rebind_action(action_name: String, new_key: Key):
	update_action(action_name, new_key)

#endregion

## 游戏设置的预加载(因此应当将)
func _config_return() -> Dictionary:
	var configfile := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	var config: Dictionary
	if not configfile or use_default_config:
		config = SoraConstant.BASIC_SETTING 
	else:
		var json_for_setting := configfile.get_as_text()
		config = JSON.parse_string(json_for_setting) as Dictionary
	
	return config

func _config_info_parser(_setting: Dictionary):
	var keymap = _setting["keymap"] as Dictionary 
	var display = _setting["display"] as Dictionary

	for keyword in keymap.keys():
		update_action(keyword, keymap[keyword])

	is_initialized = true

func _config_changed(_changed_config: Dictionary):
	var configfile := FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	var json = JSON.new()
	var jsoninfo = json.stringify(_changed_config)

	configfile.store_string(jsoninfo)
