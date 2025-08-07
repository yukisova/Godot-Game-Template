class_name InteractRay
extends BoxRay

var interact_target: Entity

func _enter_tree() -> void:
	collision_mask = Main.PhysicsLayer.Interactable

func _update(_delta: float):
	force_raycast_update()
	if is_colliding():
		var collider = get_collider()
		if collider.get_parent() is Entity:
			interact_target = collider.get_parent()
	elif interact_target:
		interact_target = null
