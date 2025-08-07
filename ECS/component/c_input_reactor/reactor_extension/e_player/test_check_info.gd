extends ReactorExtension

func _listen():
	if Input.is_key_pressed(KEY_1):
		## 查看全局状态机现在的状态
		var state = SGameState.state_machine._get_leaf_state()
		print(state.name)
