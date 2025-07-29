##@editing:	Sora
##@describe:	玩家的移动(播放对应的动画)
##			state_move
@tool
extends StateHfsm

@export var vector_move: MoveStrategy
@export var c_animation_ez: C_Texture

func _enter():
	pass

func _update(delta: float) -> void:
	var vector = vector_move.get("move_vector") as Vector2
	if (vector.is_zero_approx()):
		state_transition.emit(get_transition_state())
	
func _fixed_update(delta: float) -> void:
	var direction = vector_move.get("toward_direction") as Vector2
	var base_sprite = c_animation_ez._get_texture()
	if direction.is_equal_approx(Vector2.UP):
		base_sprite.play("walk_u")
	if direction.is_equal_approx(Vector2.RIGHT):
		base_sprite.play("walk_r")
	if direction.is_equal_approx(Vector2.DOWN):
		base_sprite.play("walk_d")
	if direction.is_equal_approx(Vector2.LEFT):
		base_sprite.play("walk_l")
		
	
func _exit():
	var base_sprite = c_animation_ez._get_texture()
	base_sprite.stop()
