extends IUi

@onready var control: Control = $Control

func _ready() -> void:
	control.modulate = Color.TRANSPARENT
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(control, "modulate", Color.WHITE, 2.0)
	tween.tween_property(control, "modulate", Color.TRANSPARENT, 1.0).set_delay(1.0)
	tween.tween_callback(func():
			# 验证当前状态机状态
		var main_sm_current_state = SGameState.state_machine._get_active_state()
		if main_sm_current_state is GamingChildStateMachine:
			main_sm_current_state.update_trigger = true
		else:
			push_error("暂停UI: 状态机错误，当前不在游戏子状态机中")
		unspawn()
	)
