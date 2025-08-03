##@editing:	Sora
##@describe:	暂停界面
extends IUi

@export_group("控件", "control_")
@export var control_game_retry: Button
@export var control_game_setting: LinkageButton
@export var control_return_menu: Button

func _initilize_info(_context: Dictionary):
	control_game_retry.pressed.connect(func():
		unspawn()
		)
	control_game_setting.pressed.connect(func():
		control_game_setting._execute()
		get_child(0).hide()
		control_game_setting.linkage_target.window_closed.connect(func():
			get_child(0).show()
			control_game_setting.linkage_target.queue_free()
			)
		)
	control_return_menu.pressed.connect(func():
		var main_sm_current_state = SGameState.state_machine._get_active_state()
		if main_sm_current_state is GamingChildStateMachine:
			main_sm_current_state.update_trigger = true
		else:
			push_error("WTF错误, 怎么可能不是在游戏中子状态机下？")
		)
