## 暂停界面UI - 游戏暂停时显示的控制面板
extends UIView

@export var control_game_retry: Button
@export var control_game_setting: LinkageButton
@export var control_return_menu: Button

var ui_controller: UIController

func _initialize(_context: Dictionary):
	ui_controller = _context["ui_controller"]

	control_game_retry.pressed.connect(_on_control_game_retry_pressed)
	control_game_setting.pressed.connect(_on_control_game_setting_pressed)
	control_return_menu.pressed.connect(_on_control_return_menu_pressed)


func _on_control_game_retry_pressed():
	ui_controller.unspawn()  # 关闭暂停界面，恢复游戏

func _on_control_game_setting_pressed():
	control_game_setting._execute()
	get_child(0).hide()  # 隐藏暂停界面
		
	# 监听设置界面关闭事件
	control_game_setting.linkage_target.window_closed.connect(func():
		get_child(0).show()  # 重新显示暂停界面
		control_game_setting.linkage_target.queue_free()  # 清理设置界面
	)

func _on_control_return_menu_pressed():
	# 验证当前状态机状态
	var main_sm_current_state = SGameState.state_machine.get_active_state()
	if main_sm_current_state is GamingChildStateMachine:
		main_sm_current_state.update_trigger = true
	else:
		push_error("暂停UI: 状态机错误，当前不在游戏子状态机中")
