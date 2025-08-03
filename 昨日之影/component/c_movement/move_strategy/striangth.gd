## @editing: Sora [br]
## @describe: 直线飞行: 适用于CharacterBody
extends MoveStrategy

var direction: Vector2

func _check_and_init():
	if binding_entity.main_control is not CharacterBody2D:
		push_error("直线飞行组件只适用于CharacterBody")
	
	get_tree().create_timer(2.0).timeout.connect(func():
		binding_entity.queue_free()
		)
		
	direction = blackboard.get_value("start_direction")
	
func _update(_delta: float):
	binding_entity.main_control.velocity = direction * 5000 * _delta
	var current_pos = binding_entity.main_control.global_position
	
	if current_pos.distance_to(blackboard.get_value("target_position")) < 10:
		binding_entity.queue_free()
	binding_entity.main_control.move_and_slide()
