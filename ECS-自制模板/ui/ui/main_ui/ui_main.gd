## 游戏的主菜单，包含自动加载的开场动画，与游戏的所有选项，以后肯定会经常用到，因此现在先开始
extends IUi

@export var continue_game_button: FuncButton
@export var start_game_button: FuncButton
@export var load_game_button: FuncButton
@export var game_setting_button: LinkageButton
@export var quit_game_button: FuncButton

func _ready() -> void:
	## 淡入主菜单
	var control = get_child(0) as Control
	control.modulate.a = 0
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(control, "modulate:a", 1.0, 1.0)
	
	## 绑定按钮
	#continue_game_button.pressed.connect(func():\
		#
	#)
	start_game_button.pressed.connect(Callable(func(_args):
		var game_state_machine = Main.s_game_state.state_machine as StateMachine 
		var s_mapdata = Main.s_map_data as S_Mapdata
		
		var current_state = game_state_machine._get_active_state()
		if current_state is GameStartState:
			current_state.update_trigger = true
			s_mapdata.map_info_registered.emit(_args[0] as PackedScene)
			unspawn()
		else:
			push_error("当前出现问题: 主菜单场景状态机错误！当前状态名:%s"%[current_state.name])).bind(start_game_button.args)
	)
	## TODO 游戏存档模块：加载游戏逻辑还有待进步
	load_game_button.pressed.connect(Callable(func(_args):
		var game_state_machine = Main.s_game_state.state_machine as StateMachine 
		var s_load_and_save = Main.s_load_and_save
		
		var current_state = game_state_machine._get_active_state()
		if current_state is GameStartState:
			#current_state.update_trigger = true
			s_load_and_save.emit_signal("loading_started")
			#unspawn()
		else:
			push_error("当前出现问题: 主菜单场景状态机错误！当前状态名:%s"%[current_state.name])).bind(load_game_button.args)
	)
	## TODO 游戏设置界面：该怎么实现复杂的配置存储？
	game_setting_button.pressed.connect(func():
		game_setting_button._execute()
		get_child(0).hide()
		game_setting_button.linkage_target.connect("window_closed", func():
			get_child(0).show()
			game_setting_button.linkage_target.queue_free()
		)
	)
	quit_game_button.pressed.connect(func():
		get_tree().quit()
	)
