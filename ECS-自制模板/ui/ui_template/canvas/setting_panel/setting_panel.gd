extends Control

signal window_closed

@export var keymap_container: VBoxContainer
@export var display_setting: VBoxContainer
@export var audio_setting: VBoxContainer

@export var confirm: FuncButton
@export var reset: FuncButton

var current_config: Dictionary
var current_setting: Dictionary = {}


func _enter_tree() -> void:
	confirm.pressed.connect(Callable(func(_args):
		Main.s_global_config.emit_signal("presaving_started", current_config)
		window_closed.emit()
		).bind(confirm.args)
	)
	reset.pressed.connect(Callable(func(_args):
		Main.s_global_config._resetup()
		).bind(reset.args)
	)
	current_config = Main.s_global_config.call("_config_return") as Dictionary
	current_config = current_config.duplicate(true)

func _ready() -> void:
	var keymap_info_prototype = get_node("%KeymapInfo") as Button
	
	var keymap = current_config["keymap"]
	for action_name in keymap.keys():
		var keymap_record = keymap_info_prototype.duplicate() as Button
		keymap_info_prototype.get_parent().add_child(keymap_record)
		keymap_record.text = action_name
		keymap_record.get_child(0).text = "KEY_"+OS.get_keycode_string(keymap[action_name])
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

func _unhandled_input(event: InputEvent) -> void:
	if !current_setting.is_empty():
		if current_setting.has("keymap"):
			if event is InputEventKey and event.is_pressed():
				var pressed_key = event.keycode
				var target_action = current_setting["keymap"]["name"]
				var target = current_setting["keymap"]["target"]
				
				if __key_unique_check(target_action, pressed_key):
					current_config["keymap"][target_action] = pressed_key
					
					target.get_child(0).text = "KEY_"+OS.get_keycode_string(current_config["keymap"][target_action])
				else:
					print("按键映射出现冲突！！！")
				
				current_setting.clear()
				target.set_pressed_no_signal(false)
					

## 私有方法
func __key_unique_check(target_action: String, new_keycode: Key) :
	var flag: bool = true
	for key in current_config["keymap"].keys():
		if target_action == key:
			continue
		if new_keycode == current_config["keymap"][key]:
			flag = false
			break
	return flag
