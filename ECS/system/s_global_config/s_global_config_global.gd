## @editing: Sora [br]
## @describe: 全局配置系统 - 管理游戏设置的预加载和持久化存储
## 
## 该系统与存档系统类似，但专门负责游戏设置的管理，包括键位绑定、
## 显示设置、音频设置等。设置信息在游戏启动时预加载，确保配置
## 在系统初始化前就已经生效。
## 
## 核心功能：
## - 设置预加载：游戏启动时立即加载用户配置
## - 键位管理：动态键位绑定和重新映射
## - 配置持久化：自动保存用户的配置更改
## - 默认配置：支持回退到默认设置
## - 热更新：运行时应用配置更改
## 
## 配置类型：
## - 键位映射：自定义按键绑定
## - 显示设置：分辨率、全屏、垂直同步等
## - 音频设置：主音量、效果音量、背景音乐音量
## - 游戏设置：难度、语言、自动保存等
## 
## 特性：
## - 预加载机制：确保配置在游戏逻辑启动前生效
## - JSON存储：使用JSON格式存储配置文件
## - 静态访问：提供静态方法方便全局访问
## - 错误恢复：配置文件损坏时自动使用默认设置
## 
## TODO: 当前缺少完整的设置记录功能，主要依赖默认设置
extends ISystem

## 配置预加载开始信号
## 当开始加载用户配置时发出，传递加载的设置字典
## @param _loading_setting: 加载的配置数据
signal preloading_started(_loading_setting: Dictionary)

## 配置保存开始信号
## 当用户更改配置需要保存时发出，传递变更的配置
## @param _changed_config: 更改的配置数据
signal presaving_started(_changed_config: Dictionary)

## 使用默认配置标志
## 为true时忽略用户配置文件，强制使用默认设置
@export var use_default_config: bool

## 配置文件路径
## 用户配置文件的存储位置
const CONFIG_PATH := "user://config.sav"

## 初始化状态标志
## 标记配置系统是否已完成初始化
static var is_initialized = false

## 系统初始化
## 连接配置信号并立即加载用户配置
func _enter_tree() -> void:
	# 连接配置处理信号
	preloading_started.connect(_config_info_parser)
	presaving_started.connect(_config_changed)
	
	# 立即加载配置文件
	var config = _config_return()
	
	preloading_started.emit.call_deferred(config)

## 系统设置
## 配置系统的基础设置（预留接口）
func _setup():
	# 预留给将来的配置系统扩展
	pass

## 系统重置
## 配置系统重置逻辑（当前无需特殊处理）
func _resetup():
	# 配置信息通常不需要在游戏重置时清理
	pass

#region 键位绑定管理
## 更新动作映射
## 为指定动作设置新的按键绑定
## @param action_name: 动作名称
## @param key: 新的按键代码
static func update_action(action_name: String, key):
	# 确保动作存在于输入映射中
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
		print("配置系统: 创建新的输入动作 -> ", action_name)
	
	# 清除现有的按键绑定
	InputMap.action_erase_events(action_name)
	
	# 创建新的键盘输入事件
	var input_event = InputEventKey.new()
	input_event.keycode = key
	
	# 添加新的按键绑定
	InputMap.action_add_event(action_name, input_event)
	
	print("配置系统: 设置按键绑定 -> ", action_name, " = ", OS.get_keycode_string(key))

## 重新绑定动作
## 为指定动作重新绑定按键（update_action的别名）
## @param action_name: 动作名称
## @param new_key: 新的按键
static func rebind_action(action_name: String, new_key: Key):
	update_action(action_name, new_key)
#endregion

## 配置文件加载
## 从配置文件或默认设置中加载配置数据
## @return: 配置数据字典
## 
## FIXME: 当前实现的问题
## 游戏缺少完整的设置记录功能，主要依赖SoraConstant中的默认设置
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

## 配置信息解析
## 解析加载的配置并应用到游戏系统中
## @param _setting: 配置数据字典
func _config_info_parser(_setting: Dictionary):
	print("配置系统: 开始解析配置数据")
	
	# 解析键位映射配置
	var keymap = _setting.get("keymap", {}) as Dictionary
	var _display = _setting.get("display", {}) as Dictionary
	
	print("配置系统: 找到 ", keymap.size(), " 个键位绑定")
	
	# 应用所有键位绑定
	for keyword in keymap.keys():
		update_action(keyword, keymap[keyword])
	
	# TODO: 应用显示设置
	# 例如：分辨率、全屏模式、垂直同步等
	
	# TODO: 应用音频设置
	# 例如：主音量、音效音量、背景音乐音量等
	
	# 验证关键按键是否正确设置
	if InputMap.has_action("interact"):
		print("配置系统: 'interact' 动作已正确创建")
	else:
		push_warning("配置系统: 'interact' 动作未能创建")
	
	# 标记配置系统已初始化
	is_initialized = true
	print("配置系统: 配置解析完成，系统已初始化")

## 配置更改处理
## 将用户的配置更改保存到文件
## @param _changed_config: 更改的配置数据字典
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
