@tool
class_name WeaponAttackNode
extends Node2D

@export var projectile_scene: PackedScene:
	set(v):
		var node = v.instantiate()
		if node is IEntity and node.main_control.is_in_group("temp"):
			projectile_scene = v
		node.queue_free()

@export var fire_point: Marker2D

## 玩家朝指定的方向发射子弹，此时会消耗子弹或者玩家的耐力
func _attack():
	var projectile = projectile_scene.instantiate() as IEntity
	projectile.init_data_variant = {
		"global_position":fire_point.global_position,
		"start_direction":fire_point.global_position.direction_to(get_global_mouse_position()).normalized(),
		
	}
	SMapData.current_level.add_child(projectile)
	
	
