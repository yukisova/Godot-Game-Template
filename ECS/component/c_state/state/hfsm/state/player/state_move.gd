## SORA @editing: Sora [br]
## @describe: 玩家的移动(播放对应的动画)
## @filename: state_move
@tool
extends StateHfsm

@export var vector_move: MoveStrategy
@export var c_texture: C_Texture

func _enter():
	pass

func _update(_delta: float) -> void:
	var vector:Vector2 = vector_move.move_vector
	if (vector.is_zero_approx()):
		state_transition.emit(get_transition_state())
	
	var animation: AnimationPlayer = c_texture.animation_player
	if Input.is_action_pressed("move_l"):
		animation.play("people_action/walk_l")
	elif Input.is_action_pressed("move_r"):
		animation.play("people_action/walk_r")
	elif Input.is_action_pressed("move_u"):
		animation.play("people_action/walk_u")
	elif Input.is_action_pressed("move_d"):
		animation.play("people_action/walk_d")
		

func _exit():
	c_texture.animation_player.stop()
