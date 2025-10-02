extends UIController

@export var control: Control
@export var label: Label

func _initilize_info(_context: Dictionary) -> void:
	var type = _context["type"]
	match type:
		0:
			label.text = "游戏结束，你被看见了"
		1:
			label.text = "游戏结束，你离开了这里"

	control.modulate = Color.TRANSPARENT
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(control, "modulate", Color.WHITE, 2.0)
	tween.tween_property(control, "modulate", Color.TRANSPARENT, 1.0).set_delay(1.0)
	await tween.step_finished
	# 验证当前状态机状态
	var main_sm_current_state = SGameState.state_machine.get_active_state()
	if main_sm_current_state is GamingChildStateMachine:
		main_sm_current_state.update_trigger = true
	else:
		push_error("暂停UI: 状态机错误，当前不在游戏子状态机中")
	
	unspawn()
