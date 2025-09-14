class_name MoveStrategy
extends IUpdateAction

var move_vector: Vector2

func _initialize():
	pass

func _update(_delta: float):
	pass

func _reset():
	pass

func _set_move_vector(vector: Vector2):
	pass

func _get_move_vector() -> Vector2:
	return Vector2.ZERO

## 设置目标应当面朝的方向
## [param source]: 设置目标的源节点，用于验证
## [param vector]: 目标应当面朝的方向
func _set_target_direction(source: Node2D, vector: Vector2):
	pass