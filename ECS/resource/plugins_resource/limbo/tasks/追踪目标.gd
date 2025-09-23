extends BTAction

func _enter() -> void:
	var sight_box: SightBox = blackboard.get_var("sight_box", null)
	var sound_box: SoundBox = blackboard.get_var("sound_box", null, false)
	var c_navigation_agent: CNavigationAgent = blackboard.get_var("c_navigation_agent", null)
	if c_navigation_agent:
		if sight_box:
			var target_position = sight_box.get_target_position()
			if target_position != Vector2.INF:
				c_navigation_agent.set_target_position(target_position)
		elif sound_box:
			print("根据声音来源进行追踪")
			var target_position = sound_box.get_target_position()
			if target_position != Vector2.INF:
				c_navigation_agent.set_target_position(target_position)

func _tick(_delta: float) -> Status:
	var sight_box: SightBox = blackboard.get_var("sight_box", null)
	var sound_box: SoundBox = blackboard.get_var("sound_box", null, false)
	var c_navigation_agent: CNavigationAgent = blackboard.get_var("c_navigation_agent", null)
	if c_navigation_agent.nav_agent.is_navigation_finished():
		return Status.SUCCESS

	if sight_box:
		if sight_box.sight_target.is_empty():
			pass
		else:
			var target_direction: Vector2 = sight_box.get_target_direction()
			if !target_direction.is_zero_approx():
				var move_vector: MoveStrategyVector = blackboard.get_var("move_vector", null)
				move_vector._set_target_direction(null, target_direction)
			return Status.RUNNING
	
	if sound_box:
		## 可疑声音消失，离开警戒状态
		if sound_box.sound_target.is_empty():
			return Status.FAILURE
		else:
			var target_direction: Vector2 = sound_box.get_target_direction()
			if !target_direction.is_zero_approx():
				var move_vector: MoveStrategyVector = blackboard.get_var("move_vector", null)
				move_vector._set_target_direction(null, target_direction)

	return Status.RUNNING
