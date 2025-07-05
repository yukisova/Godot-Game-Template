extends Interaction

@export var c_animation_ez : IComponent
@export var collision_shape: CollisionShape2D

func _on_interact_activated(component: IComponent):
	var base_sprite = c_animation_ez.get("base_sprite") as AnimatedSprite2D

	base_sprite.play("open_door")
	await base_sprite.animation_finished
	collision_shape.disabled = true

func _on_interact_deactivated(component: IComponent):
	var base_sprite = c_animation_ez.get("base_sprite") as AnimatedSprite2D
	base_sprite.play("close_door")
	await base_sprite.animation_finished
	collision_shape.disabled = false
	
