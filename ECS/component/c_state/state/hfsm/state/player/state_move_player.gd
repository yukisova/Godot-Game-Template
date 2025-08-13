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
		state_transition.emit(get_transition_state("idle"))

func _exit():
	pass
