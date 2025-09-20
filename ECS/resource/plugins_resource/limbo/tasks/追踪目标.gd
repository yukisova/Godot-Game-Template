extends BTAction

func _enter() -> void:
	var sight_box: SightBox = blackboard.get_var("sight_box", null)
	var c_navigation_agent: CNavigationAgent = blackboard.get_var("c_navigation_agent", null)
	if c_navigation_agent:
		var target_position = sight_box.get_target_position()
		if target_position != Vector2.INF:
			c_navigation_agent.set_target_position(target_position)

func _tick(delta: float) -> Status:
	var sight_box: SightBox = blackboard.get_var("sight_box", null)
	var c_navigation_agent: CNavigationAgent = blackboard.get_var("c_navigation_agent", null)
	if c_navigation_agent.nav_agent.is_navigation_finished():
		return Status.SUCCESS

	if sight_box:
		if sight_box.sight_target.is_empty():
			return Status.FAILURE
		else:
			var target_direction: Vector2 = sight_box.get_target_direction()
			if !target_direction.is_zero_approx():
				var move_vector: MoveStrategyVector = blackboard.get_var("move_vector", null)
				move_vector._set_target_direction(null, target_direction)

	return Status.RUNNING
