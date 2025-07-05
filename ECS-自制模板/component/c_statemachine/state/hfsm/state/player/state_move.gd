## state_move
@tool
extends State

@export var c_move: IComponent
@export var c_animation_ez: IComponent

func _enter():
	pass

func _update(delta: float) -> void:
	var vector = c_move.get("move_vector") as Vector2
	if (vector.is_zero_approx()):
		state_transition.emit(parent_to_self)
	
func _fixed_update(delta: float) -> void:
	var direction = c_move.get("toward_direction") as Vector2
	var base_sprite = c_animation_ez.get("base_sprite") as AnimatedSprite2D
	if direction.is_equal_approx(Vector2.UP):
		base_sprite.play("walk_u")
	if direction.is_equal_approx(Vector2.RIGHT):
		base_sprite.play("walk_r")
	if direction.is_equal_approx(Vector2.DOWN):
		base_sprite.play("walk_d")
	if direction.is_equal_approx(Vector2.LEFT):
		base_sprite.play("walk_l")
		
	
func _exit():
	var base_sprite = c_animation_ez.get("base_sprite") as AnimatedSprite2D
	base_sprite.stop()
