extends UIView

@export var continue_game_button: FuncButton
@export var test_game_button: FuncButton
@export var start_game_button: FuncButton
@export var load_game_button: FuncButton
@export var game_setting_button: LinkageButton
@export var quit_game_button: FuncButton


func _initialize(_context: Dictionary):
	controller = _context["controller"]

	continue_game_button.pressed.connect(_on_continue_game_button_pressed.bind(continue_game_button.args))
	test_game_button.pressed.connect(_on_test_game_button_pressed.bind(test_game_button.args))
	start_game_button.pressed.connect(_on_start_game_button_pressed.bind(start_game_button.args))
	load_game_button.pressed.connect(_on_load_game_button_pressed.bind(load_game_button.args))
	game_setting_button.pressed.connect(_on_game_setting_button_pressed)
	quit_game_button.pressed.connect(_on_quit_game_button_pressed.bind(quit_game_button.args))

	# 设置淡入动画效果
	modulate.a = 0
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 1.0, 1.0)

	## 会预先加载游戏场景，并等待玩家按下游戏开始
	_preload_game_scene()

func _preload_game_scene():
	await SLoadAndSave.preload_game_in_ui_main()

	SViewportManager.camera_zoom_change_immediately(SMainController._get_player_info_by_index(0).main_control, Vector2(7,7))
	SViewportManager.camera_strategy_change(SMainController._get_player_info_by_index(0).main_control, CFSAttachPlayer.new(Vector2(30, -10)))
	SUiSpawner.current_hud["transition"].try_hide()

func _on_continue_game_button_pressed(_args):
	pass

func _on_test_game_button_pressed(_args):
	print("主菜单UI: 启动测试游戏")
	# SMainController.play_type = play_type
	var game_state_machine = SGameState.state_machine as StateMachine 
	
	var current_state = game_state_machine.get_active_state()
	if current_state is GameStartState:
		current_state.update_trigger = true
		# 动态加载测试场景，避免循环引用
		# var test_scene = load(_args[0] as String) as PackedScene
		# SMapData.map_registered.emit(test_scene)
		SAudioMaster.play_music(null)
		controller.unspawn()
	else:
		push_error("主菜单UI: 状态机错误，当前状态: %s" % [current_state.name])

func _on_start_game_button_pressed(_args):
	print("主菜单UI: 开始新游戏")
	SAudioMaster.play_music(null)
	
	var game_state_machine = SGameState.state_machine as StateMachine 
	
	var current_state = game_state_machine.get_active_state()
	if current_state is GameStartState:
		current_state.update_trigger = true
		# 动态加载测试场景，避免循环引用
		# var test_scene = load(_args[0] as String) as PackedScene
		# SMapData.map_registered.emit(test_scene)
		SAudioMaster.play_music(null)
		controller.unspawn()
	else:
		push_error("主菜单UI: 状态机错误，当前状态: %s" % [current_state.name])

func _on_load_game_button_pressed(_args):
	print("主菜单UI: 加载游戏存档")
	var game_state_machine = SGameState.state_machine as StateMachine 
	
	var current_state = game_state_machine.get_active_state()
	if current_state is GameStartState:
		current_state.update_trigger = true
		SAudioMaster.play_music(null)
		controller.unspawn()
	else:
		push_error("主菜单UI: 状态机错误，当前状态: %s" % [current_state.name])

func _on_game_setting_button_pressed():
	print("主菜单UI: 打开游戏设置")
	game_setting_button._execute()
	get_child(0).hide()
	game_setting_button.linkage_target.window_closed.connect(func():
		get_child(0).show()
		controller.unspawn()
	)

func _on_quit_game_button_pressed(_args):
	get_tree().quit()
