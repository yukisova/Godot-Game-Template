extends ReactorExtension

@export var interact_ray: InteractRay

func _listen():
	var vector = interact_ray.global_position.direction_to(interact_ray.get_global_mouse_position())
	interact_ray.rotation = vector.angle()
	
	if Input.is_action_just_pressed("interact"):
		if interact_ray.interact_target:
			interact_ray.interact_target.entity_ray_interact.emit(c_input_reactor.component_owner)
