## state_using
@tool
extends State

@export var c_status: C_Status
@export var c_move: IComponent
@export var c_animation_ez: IComponent
@export var hitbox: Hitbox

func _enter():
	var toolname = c_status.status_extension["Equipment"].get(&"current_tool")
	var direction = c_move.get("toward_direction") as Vector2
	var base_sprite = c_animation_ez.get("base_sprite") as AnimatedSprite2D
	if direction.is_equal_approx(Vector2.UP):
		base_sprite.play(toolname+"_u")
		hitbox.collision.position = Vector2(0,-13)
	if direction.is_equal_approx(Vector2.RIGHT):
		base_sprite.play(toolname+"_r")
		hitbox.collision.position = Vector2(12,0)
	if direction.is_equal_approx(Vector2.DOWN):
		base_sprite.play(toolname+"_d")
		hitbox.collision.position = Vector2(0,13)
	if direction.is_equal_approx(Vector2.LEFT):
		base_sprite.play(toolname+"_l")
		hitbox.collision.position = Vector2(-12,0)
	
	await get_tree().create_timer(0.2).timeout
	hitbox.collision.disabled = false
	

func _fixed_update(_delta: float) -> void:
	var base_sprite = c_animation_ez.get("base_sprite") as AnimatedSprite2D
	if (!base_sprite.is_playing()):
		state_transition.emit(parent_to_self)


func _exit():
	var base_sprite = c_animation_ez.get("base_sprite") as AnimatedSprite2D
	base_sprite.stop()
	hitbox.collision.disabled = true
