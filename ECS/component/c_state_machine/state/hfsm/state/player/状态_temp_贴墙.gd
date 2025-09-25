## 玩家贴墙状态 - 玩家角色贴墙时的状态实现
@tool
extends StateTemp

@export var vector_move: MoveStrategyVector
@export var movement_input: REMovementInput

@export var player: CharacterBody2D
var collision_shape: CollisionShape2D

func _ready() -> void:
	if (Engine.is_editor_hint()): return
	collision_shape = player.get_node("CollisionShape2D")

func _enter() -> void:
	vector_move.fixed_move_callable = _callable_movement
	vector_move.fixed_move_callable_setted = true

func _exit() -> void:
	vector_move.fixed_move_callable_setted = false
	vector_move.fixed_move_callable = Callable()

func _blur_update(_delta: float) -> void: pass
func _update(_delta: float) -> void: pass
func _fixed_update(_delta: float) -> void: pass

func _pause() -> void: pass
func _continue() -> void: pass

## 所谓的可以
func _callable_movement(_delta: float) -> void:
	var move_vector = movement_input.get_move_vector()
	player.velocity = move_vector * 100

	if player.get_slide_collision_count() > 0 and move_vector.length() > 0:
		var collision = player.get_slide_collision(0)
		var collision_normal = collision.get_normal()

		var wall_trangent = Vector2(-collision_normal.y, collision_normal.x)
		var tangent_movement = wall_trangent.dot(move_vector)

		var movement_threshold = 0.1

		var current_move_direction: Vector2

		if abs(tangent_movement) < movement_threshold:
			current_move_direction = Vector2.ZERO
		else:
			if abs(collision_normal.y) > abs(collision_normal.x):
				if collision_normal.y > 0:
					if tangent_movement < 0:
						current_move_direction = Vector2.RIGHT
					else:
						current_move_direction = Vector2.LEFT
				else:
					if tangent_movement > 0:
						current_move_direction = Vector2.RIGHT
					else:
						current_move_direction = Vector2.LEFT
			else:
				if collision_normal.x > 0:
					if tangent_movement < 0:
						current_move_direction = Vector2.UP
					else:
						current_move_direction = Vector2.DOWN
				else:
					if tangent_movement > 0:
						current_move_direction = Vector2.UP
					else:
						current_move_direction = Vector2.DOWN
		
		if fix_movement(current_move_direction, wall_trangent, collision_normal):
			if current_move_direction == Vector2.RIGHT or current_move_direction == Vector2.LEFT:
				move_vector = Vector2(0, move_vector.y)
			elif current_move_direction == Vector2.UP or current_move_direction == Vector2.DOWN:
				move_vector = Vector2(move_vector.x, 0)

	player.velocity = move_vector * 100
	player.move_and_slide()

func fix_movement(current_move_direction: Vector2, wall_trangent: Vector2, collision_normal: Vector2) -> bool:
	var world_2d = player.get_world_2d()
	var space_state = world_2d.direct_space_state

	var ray_start
	var check_size = 0
	var therehold = 3
	match current_move_direction:
		Vector2.RIGHT:
			ray_start = player.global_position + (collision_shape.shape.size.x / 2 + therehold) * Vector2.RIGHT
			check_size = collision_shape.shape.size.y
		Vector2.LEFT:
			ray_start = player.global_position + (collision_shape.shape.size.x / 2 + therehold) * Vector2.LEFT
			check_size = collision_shape.shape.size.y
		Vector2.UP:
			ray_start = player.global_position + (collision_shape.shape.size.y / 2 + therehold) * Vector2.UP
			check_size = collision_shape.shape.size.x
		Vector2.DOWN:
			ray_start = player.global_position + (collision_shape.shape.size.y / 2 + therehold) * Vector2.DOWN
			check_size = collision_shape.shape.size.x
		Vector2.ZERO:
			ray_start = player.global_position

	var ray_end = ray_start - collision_normal * check_size

	var query = PhysicsRayQueryParameters2D.create(ray_start, ray_end)
	query.exclude = [player.get_rid()]
	var result = space_state.intersect_ray(query)

	if result.is_empty():
		return true
	else:
		return false
