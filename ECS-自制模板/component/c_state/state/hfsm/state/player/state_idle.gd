##@editing:	Sora
##@describe:	玩家的站立(播放对应的动画)
##			state_idle.gd
@tool
extends StateHfsm

@export var vector_move: MoveStrategy
@export var c_texture: C_Texture

## HACK 游戏存档模块：测试用，会移除
@export var test_c_input: C_InputReactor

func _enter():
	pass

func _update(_delta: float) -> void:
	super._update(_delta)
	
	var vector = vector_move.get("move_vector") as Vector2
	if (!vector.is_zero_approx()):
		state_transition.emit(get_transition_state())


func _fixed_update(_delta: float) -> void:
	var direction = vector_move.toward_direction as Vector2
	var base_sprite = c_texture._get_texture() ## 要根据实际情况修改
	if direction.is_equal_approx(Vector2.UP):
		base_sprite.play("idle_u")
	if direction.is_equal_approx(Vector2.RIGHT):
		base_sprite.play("idle_r")
	if direction.is_equal_approx(Vector2.DOWN):
		base_sprite.play("idle_d")
	if direction.is_equal_approx(Vector2.LEFT):
		base_sprite.play("idle_l")
	
	test_c_input._try_save_game()
	
func _exit():
	#var base_sprite = c_animation_ez.get("base_sprite") as AnimatedSprite2D
	#base_sprite.stop()
	pass

func _listen():
	pass
