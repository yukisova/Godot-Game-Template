class_name EffectMarker
extends BoxMarker

var current_effect: Dictionary[String, GPUParticles2D]

@export var hurt_effect: PackedScene
func _enter_tree() -> void:
	box_marker_name = CCollisionBox.BoxMarkerType.EFFECT

func _update(_delta: float) -> void:
	pass

## 激活受伤的粒子
func hurted_effect(_position: Vector2, direction: Vector2):
	if current_effect.has("hurted"):
		var hurted = current_effect["hurted"]
		hurted.global_position = _position
		hurted.process_material.direction = Vector3(direction.x, direction.y, 0)
		hurted.one_shot = true
		hurted.emitting = true
	else:
		current_effect["hurted"] = hurt_effect.instantiate()
		var hurted = current_effect["hurted"]
		add_child(hurted)
		hurted.global_position = _position
		hurted.process_material.direction = Vector3(direction.x, direction.y, 0)
		hurted.one_shot = true
		hurted.emitting = true
