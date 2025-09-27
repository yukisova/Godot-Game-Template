@tool
@abstract class_name IHitbox
extends BoxCollision

var binding_action: AttackAction

func get_hit_effects() -> Array[IHitEffect]:
	return binding_action._get_hit_effects()

var collision: Array[CollisionShape2D]

func _enter_tree() -> void:
	for child in get_children():
		if child is CollisionShape2D:
			collision.append(child)

	box_collision_name = CCollisionBox.BoxCollisionName.HIT
	collision_layer = Main.PhysicsLayer.Breakable
	collision_mask = Main.PhysicsLayer.Wall | Main.PhysicsLayer.Breakable

func _initialize():
	pass
