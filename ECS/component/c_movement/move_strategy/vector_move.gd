## @editing: Sora [br]
## @describe: 以向量的方式进行移动，分为输入控制和AI控制两种，对应玩家与其他实体
extends MoveStrategy


@export var c_input: C_InputReactor = null ## 是否拥有Input组件,
## 移动方向
var move_vector: Vector2:
	get:
		if binding_entity.main_control is CharacterBody2D:
			if c_input:
				var input_vector = c_input.input_vector_dict.move
				toward_direction = input_vector.normalized()
				return input_vector
			else:
				toward_direction = move_vector.normalized()
				return move_vector
		else:
			push_error("目标不可被移动，请使用其他的方案")
			return Vector2.ZERO
	set(value):
		move_vector = value

## 移动速度
@export var move_speed: float
## 面对的方向
var toward_direction: Vector2

func _check_and_init():
	pass

func _update(_delta: float):
	var body = binding_entity.main_control
	
	if c_input: ## 如果存在c_input的引用， 则当前对象可移动
		if (!move_vector.is_zero_approx()):
			body.velocity = body.velocity.lerp(move_vector * _delta * 10 * move_speed, _delta * 10)
		else:
			body.velocity = body.velocity.lerp(Vector2.ZERO, _delta * 10)
		body.move_and_slide()
