## state_idle
@tool
extends State

@export var c_move: IComponent
@export var c_animation_ez: IComponent

## HACK 游戏存档模块：测试用，会移除
@export var test_c_input: IComponent

func _enter():
	pass

func _update(_delta: float) -> void:
	var vector = c_move.get("move_vector") as Vector2
	if (!vector.is_zero_approx()):
		state_transition.emit(parent_to_self)

	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		state_transition.emit(parent_to_self, &"using")

func _fixed_update(_delta: float) -> void:
	var direction = c_move.get("toward_direction") as Vector2
	var base_sprite = c_animation_ez.get("base_sprite") as AnimatedSprite2D
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
	var base_sprite = c_animation_ez.get("base_sprite") as AnimatedSprite2D
	base_sprite.stop()
