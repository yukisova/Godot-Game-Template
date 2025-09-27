@tool
class_name HitboxRange
extends IHitbox

## 最大命中高度，超过该高度则不进行命中判定，该参数用于处理抛物线移动的子弹，
@export var max_hit_height: float = 0.0
@export var move_strategy: IUpdateAction

func _update(_delta: float):
	if move_strategy.get_current_height() > max_hit_height:
		monitorable = false
		monitoring = false
		for i in get_children():
			if i is CollisionPolygon2D or i is CollisionShape2D:
				i.debug_color = Color.BLUE_VIOLET
				i.debug_color.a = 0.5
	else:
		monitorable = true
		monitoring = true
		for i in get_children():
			if i is CollisionPolygon2D or i is CollisionShape2D:
				i.debug_color = Color.YELLOW
				i.debug_color.a = 0.5
