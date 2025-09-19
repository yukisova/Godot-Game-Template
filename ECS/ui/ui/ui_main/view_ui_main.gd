extends UIView

@export var continue_game_button: FuncButton
@export var test_game_button: FuncButton
@export var start_game_button: FuncButton
@export var load_game_button: FuncButton
@export var game_setting_button: LinkageButton
@export var quit_game_button: FuncButton

var ui_controller: UIController

func _initialize(_context: Dictionary):
	ui_controller = _context["ui_controller"]

	continue_game_button.pressed.connect(_on_continue_game_button_pressed.bind(continue_game_button.args))
	test_game_button.pressed.connect(_on_test_game_button_pressed.bind(test_game_button.args))
	start_game_button.pressed.connect(_on_start_game_button_pressed.bind(start_game_button.args))
	load_game_button.pressed.connect(_on_load_game_button_pressed.bind(load_game_button.args))
	game_setting_button.pressed.connect(_on_game_setting_button_pressed)
	quit_game_button.pressed.connect(_on_quit_game_button_pressed.bind(quit_game_button.args))

	# 设置淡入动画效果
	var control = get_child(0) as Control
	control.modulate.a = 0
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(control, "modulate:a", 1.0, 1.0)
	

func _on_continue_game_button_pressed(_args):
	pass

func _on_test_game_button_pressed(_args):
	print("主菜单UI: 启动测试游戏")
	# SMainController.play_type = play_type
	var game_state_machine = SGameState.state_machine as StateMachineHfsm 
	
	var current_state = game_state_machine._get_active_state()
	if current_state is GameStartState:
		current_state.update_trigger = true
		# 动态加载测试场景，避免循环引用
		var test_scene = load(_args[0] as String) as PackedScene
		SMapData.map_registered.emit(test_scene)
		SAudioMaster.play_music(null)
		ui_controller.unspawn()
	else:
		push_error("主菜单UI: 状态机错误，当前状态: %s" % [current_state.name])

func _on_start_game_button_pressed(_args):
	print("主菜单UI: 开始新游戏")
	SAudioMaster.play_music(null)
		
	var start_game_ui = load(_args[0] as String) as PackedScene
	SUiSpawner._spawn_ui(start_game_ui, {}, true)

func _on_load_game_button_pressed(_args):
	print("主菜单UI: 加载游戏存档")
	var game_state_machine = SGameState.state_machine as StateMachineHfsm 
	
	var current_state = game_state_machine._get_active_state()
	if current_state is GameStartState:
		current_state.update_trigger = true
		SAudioMaster.play_music(null)
		ui_controller.unspawn()
	else:
		push_error("主菜单UI: 状态机错误，当前状态: %s" % [current_state.name])

func _on_game_setting_button_pressed():
	print("主菜单UI: 打开游戏设置")
	game_setting_button._execute()
	get_child(0).hide()
	game_setting_button.linkage_target.window_closed.connect(func():
		get_child(0).show()
		ui_controller.unspawn()
	)

func _on_quit_game_button_pressed(_args):
	get_tree().quit()
