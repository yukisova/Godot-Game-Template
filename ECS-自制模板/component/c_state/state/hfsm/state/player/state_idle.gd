## @editing: Sora [br]
## @describe: 玩家的站立(播放对应的动画) [br]
## @filename: state_idle.gd
@tool
extends StateHfsm

@export var vector_move: MoveStrategy
@export var c_texture: C_Texture

func _enter():
	var vector:Vector2 = vector_move.toward_direction
	
	var animation: AnimationPlayer = c_texture.animation_player

	if vector.is_equal_approx(Vector2.LEFT):
		animation.play("people_action/idle_l")
	elif vector.is_equal_approx(Vector2.RIGHT):
		animation.play("people_action/idle_r")
	elif vector.is_equal_approx(Vector2.UP):
		animation.play("people_action/idle_u")
	elif vector.is_equal_approx(Vector2.DOWN):
		animation.play("people_action/idle_d")

func _update(_delta: float) -> void:
	super._update(_delta)
	
	var vector = vector_move.move_vector as Vector2
	if (!vector.is_zero_approx()):
		state_transition.emit(get_transition_state())
