extends Control

signal window_closed


@export_subgroup("容器")
@export var keymap_container: VBoxContainer
@export var display_setting: VBoxContainer
@export var audio_setting: VBoxContainer

@export_subgroup("控件_音频")
@export var audio_setting_master: HSlider
@export var audio_setting_sfx: HSlider
@export var audio_setting_bgm: HSlider

@export_subgroup("控件_显示")
@export var display_setting_window: MenuButton
@export var display_setting_definition: MenuButton

@export_subgroup("控件_保存")
@export var confirm: FuncButton
@export var reset: FuncButton

var current_config: Dictionary
## 当前的设置项，在没有选中要设置的目标时为空，目前只用于键位设置
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
	__init_audio()
	__init_display()
	__init_keymap()


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

#region 音频设置
func __init_audio():
	var audio = current_config["audio"]
	audio_setting_master.drag_ended.connect(func(is_changed: bool):
		if is_changed:
			Main.s_audio_master._set_volume(S_AudioMaster.AudioBusEnum.MASTER, audio_setting_master.value)
		)
	audio_setting_bgm.drag_ended.connect(func(is_changed: bool):
		if is_changed:
			Main.s_audio_master._set_volume(S_AudioMaster.AudioBusEnum.MUSIC, audio_setting_bgm.value)
		)
	audio_setting_sfx.drag_ended.connect(func(is_changed: bool):
		if is_changed:
			Main.s_audio_master._set_volume(S_AudioMaster.AudioBusEnum.SFX, audio_setting_sfx.value)
		)
#endregion

#region 显示设置
func __init_display():
	var display = current_config["display"]
	
	var popup_window = display_setting_window.get_popup()
	display_setting_window.text = __window_setting_id_to_string(display["window"])
	popup_window.id_pressed.connect(func(id):
		match id:
			SoraConstant.WINDOWED:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			SoraConstant.FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		display_setting_window.text = __window_setting_id_to_string(id)
		)
		
	var popup_definition = display_setting_definition.get_popup()
	display_setting_definition.text = __definition_setting_id_to_string(display["definition"])
	popup_definition.id_pressed.connect(func(id):
		match id:
			SoraConstant.HD:
				pass
			SoraConstant.SHD:
				pass
		display_setting_definition.text = __definition_setting_id_to_string(id)
		)
		
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
#endregion
