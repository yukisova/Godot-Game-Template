## 声音反应盒
## 用于检测声音区域，并触发声音反应
## 与CSoundEmitter组件关联，当声音区域进入该盒子时，会触发声音反应
## [br][b]编辑者:[/b] Sora
@tool
class_name SoundBox
extends BoxCollision

## 可听见的最小声音，低于该标准的声音无法被听见
@export var sound_min_limit: float = 10
## 声音前缀过滤，只有声音前缀不在过滤器中的声音才会被听见
@export var sound_prefix_fliter: Array[String]

var sound_target: Array[CSoundEmitter] = []

@export var sound_box_shape: CircleShape2D:
	set(v):
		sound_box_shape = v
		if sound_box_collision == null:
			sound_box_collision = CollisionShape2D.new()
			add_child(sound_box_collision)
		sound_box_collision.shape = v

var sound_box_collision: CollisionShape2D

func _enter_tree() -> void:
	if Engine.is_editor_hint(): return
	box_collision_name = CCollisionBox.BoxCollisionName.SOUND
	collision_layer = Main.PhysicsLayer.Sound
	collision_mask = Main.PhysicsLayer.Sound
	
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _initialize():
	pass

func get_target_direction() -> Vector2:
	if sound_target.is_empty(): return Vector2.ZERO
	return c_collision.component_body.global_position.direction_to(sound_target[-1].global_position).normalized()

func get_target_position() -> Vector2:
	if sound_target.is_empty(): return Vector2.INF
	return sound_target[-1].global_position

func _on_area_entered(area: Area2D):
	if area is ISoundArea:
		if area.sound_force < sound_min_limit:
			print(c_collision.component_owner.name, "注意到了声音-> ", area.sound_name, " 声音强度太低，无法听见")
			return
		for prefix in sound_prefix_fliter:
			if area.sound_name.begins_with(prefix):
				print(c_collision.component_owner.name, "注意到了声音-> ", area.sound_name, " 声音前缀在过滤器中，被忽略")
				return
		print(c_collision.component_owner.name, "注意到了声音-> ", area.sound_name)
		sound_target.append(area.get_parent() as CSoundEmitter)

## 声音区域消失
func _on_area_exited(area: Area2D):
	if area is ISoundArea:
		sound_target.erase(area.get_parent() as CSoundEmitter)
