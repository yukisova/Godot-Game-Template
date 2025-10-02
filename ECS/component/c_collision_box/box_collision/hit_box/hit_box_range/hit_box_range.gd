@tool
class_name HitboxRange
extends IHitbox

@export var max_hit_height: float = 0.0

func _update(_delta: float):
	var c_texture_controller: CTextureController = c_collision.get_other_component(IComponent.ComponentName.C_TEXTURE_CONTROLLER)
	if c_texture_controller.get_current_height() > max_hit_height:
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
