@tool
extends WeaponAttackNode

@export var projectile_scene: PackedScene:
	set(v):
		var node = v.instantiate()
		if node is IEntity:
			projectile_scene = v
		node.queue_free()

## 玩家朝指定的方向发射子弹，此时会消耗子弹或者玩家的耐力
func _attack():
	var projectile = projectile_scene.instantiate() as IEntity
	projectile.init_data_variant = {
		"global_position":fire_point.global_position,
		"start_direction":fire_point.global_position.direction_to(get_global_mouse_position()).normalized()
	}
	SMapData.current_level.add_child(projectile)
