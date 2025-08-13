## @editing: Sora [br]
## @describe: 游戏设置面板 - 综合性的游戏配置界面
##
## 该面板提供了游戏的各种设置选项：
## - 键位映射的自定义配置
## - 音频音量的调节控制
## - 显示模式和语言切换
## - 配置的保存和重置功能
##
## 主要功能：
## - 实时键位重映射系统
## - 音频总线音量控制
## - 窗口模式切换（窗口化/全屏）
## - 多语言支持和切换
## - 配置冲突检测和验证
##
## 技术特性：
## - 动态UI生成（键位列表）
## - 实时输入捕获和处理
## - 配置数据的深度复制
## - 信号驱动的设置同步
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
