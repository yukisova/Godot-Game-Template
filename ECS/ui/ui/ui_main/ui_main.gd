## 主菜单UI - 游戏的主要入口界面
##
## 该UI提供游戏的所有主要入口功能：
## - 开始新游戏和继续游戏
## - 加载已保存的游戏存档
## - 进入游戏设置界面
## - 退出游戏应用程序
##
## 主要特性：
## - 自动播放主菜单背景音乐
## - 平滑的淡入动画效果
## - 状态机集成的游戏流程控制
## - 模块化的按钮事件处理
##
## 界面功能：
## - 继续游戏：恢复上次游戏进度
## - 测试游戏：快速进入测试模式
## - 开始游戏：创建新的游戏流程
## - 加载游戏：从存档文件恢复游戏
## - 游戏设置：打开配置和选项界面
## - 退出游戏：关闭应用程序
##
## 架构设计：
## - 继承自 [IUi] 基类
## - 与 [SGameState] 系统的状态机集成
## - 使用 [FuncButton] 和 [LinkageButton] 组件
## - 集成 [SAudioMaster] 音频系统
##
## [br][b]编辑者:[/b] Sora
extends IUi

#region 音频配置

## 主菜单背景音乐
## 
## 在界面显示时自动播放的BGM，类型为 [AudioStream]。
@export var bgm: AudioStream

#endregion

#region UI按钮组件

@export_subgroup("依赖")

## 继续游戏按钮
## 
## 恢复最近的游戏进度，类型为 [FuncButton]。
@export var continue_game_button: FuncButton

## 测试游戏按钮
## 
## 快速进入测试模式，跳过部分初始化流程，类型为 [FuncButton]。
@export var test_game_button: FuncButton

## 开始游戏按钮
## 
## 创建新的游戏并进入开场剧情，类型为 [FuncButton]。
@export var start_game_button: FuncButton

## 加载游戏按钮
## 
## 从存档文件加载游戏状态，类型为 [FuncButton]。
@export var load_game_button: FuncButton

## 游戏设置按钮
## 
## 打开配置界面，支持键位、音频、画质等设置，类型为 [LinkageButton]。
@export var game_setting_button: LinkageButton

## 退出游戏按钮
## 
## 关闭游戏应用程序，类型为 [FuncButton]。
@export var quit_game_button: FuncButton

#endregion

#region UI初始化

## 主菜单设置
## 初始化音频、动画和按钮事件绑定
func _main_setup() -> void:
	print("主菜单UI: 开始初始化")
	
	# 播放主菜单背景音乐
	SAudioMaster.play_music(bgm)
	
	# 设置淡入动画效果
	var control = get_child(0) as Control
	control.modulate.a = 0
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(control, "modulate:a", 1.0, 1.0)
	
	# 绑定各按钮的点击事件
	_setup_button_bindings()
	
	print("主菜单UI: 初始化完成")

#endregion

#region 按钮事件绑定

## 设置所有按钮的事件绑定
func _setup_button_bindings():
	# 继续游戏按钮（暂未实现）
	# TODO: 实现继续游戏功能
	
	# 测试游戏按钮 - 快速进入测试模式
	test_game_button.pressed.connect(Callable(func(_args):
		print("主菜单UI: 启动测试游戏")
		var game_state_machine = SGameState.state_machine as StateMachineHfsm 
		
		var current_state = game_state_machine._get_active_state()
		if current_state is GameStartState:
			current_state.update_trigger = true
			# 动态加载测试场景，避免循环引用
			var test_scene = load(_args[0] as String) as PackedScene
			SMapData.map_registered.emit(test_scene)
			SAudioMaster.play_music(null)
			unspawn()
		else:
			push_error("主菜单UI: 状态机错误，当前状态: %s" % [current_state.name])
	).bind(test_game_button.args))
	
	# 开始游戏按钮 - 进入开场剧情
	start_game_button.pressed.connect(Callable(func(_args):
		print("主菜单UI: 开始新游戏")
		SAudioMaster.play_music(null)
		
		var start_game_ui = load(_args[0] as String) as PackedScene
		SUiSpawner._spawn_ui(start_game_ui, {}, true)
	).bind(start_game_button.args))
	
	# 加载游戏按钮 - 从存档恢复游戏
	# TODO: 完善游戏存档模块的加载逻辑
	load_game_button.pressed.connect(Callable(func(_args):
		print("主菜单UI: 加载游戏存档")
		var game_state_machine = SGameState.state_machine
		
		var current_state = game_state_machine._get_active_state()
		if current_state is GameStartState:
			SLoadAndSave.loading_started.emit()
			current_state.update_trigger = true
			SAudioMaster.play_music(null)
			unspawn()
		else:
			push_error("主菜单UI: 状态机错误，当前状态: %s" % [current_state.name])
	).bind(load_game_button.args))
	
	# 游戏设置按钮 - 打开设置界面
	# TODO: 实现复杂的配置存储系统
	game_setting_button.pressed.connect(func():
		print("主菜单UI: 打开游戏设置")
		game_setting_button._execute()
		get_child(0).hide()
		game_setting_button.linkage_target.window_closed.connect(func():
			get_child(0).show()
			game_setting_button.linkage_target.queue_free()
		)
	)
	
	# 退出游戏按钮 - 关闭应用程序
	quit_game_button.pressed.connect(func():
		print("主菜单UI: 退出游戏")
		get_tree().quit()
	)

#endregion
