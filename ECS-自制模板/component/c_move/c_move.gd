@tool
## 移动组件, 让目标实现移动功能
class_name C_Move
extends IComponent

## 移动方向
var move_vector: Vector2:
	get:
		if (component_body.is_in_group("people")):
			toward_direction = move_vector.normalized()
			return move_vector
		elif (component_body.is_in_group("player")):
			if (S_GlobalConfig.is_initialized):
				var input = component_owner.list_base_components.get_or_add(ComponentName.c_input)
				var input_move_info: Dictionary = input.try_input_vector()
				if (input != null):
					var input_move_vector: Vector2 = input_move_info["vec"] as Vector2
					move_vector = input_move_vector
					toward_direction = move_vector.normalized()
					return move_vector
				else:
					push_error("玩家未发现input组件")
					return Vector2.ZERO
			else:
				return Vector2.ZERO
		else:
			push_error("目标不可被移动")
			return Vector2.ZERO
	set(value):
		move_vector = value

## @e 移动速度
@export var move_speed: float

## 面对的方向
var toward_direction: Vector2

func _enter_tree() -> void:
	component_name = ComponentName.c_move


func _initialize(_owner: Entity):
	super._initialize(_owner)


## 移动逻辑的实现
func _update(delta: float):
	var body = component_body
	
	if (body is CharacterBody2D and body.is_in_group("player")):
		if (!move_vector.is_zero_approx()):
			body.velocity = body.velocity.lerp(move_vector * delta * 10 * move_speed, delta * 10)
		else:
			body.velocity = body.velocity.lerp(Vector2.ZERO, delta * 10)
		body.move_and_slide()
