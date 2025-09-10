## 声音反应盒
## 用于检测声音区域，并触发声音反应
## 与CSoundEmitter组件关联，当声音区域进入该盒子时，会触发声音反应
## [br][b]编辑者:[/b] Sora
@tool
class_name SoundBox
extends BoxCollision

## 可听见的最小声音，低于该标准的声音无法被听见
var sound_min_limit: float = 10

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

func _on_area_entered(area: Area2D):
	if area is ISoundArea:
		print(c_collision.component_owner.name, "听到了声音 -> ", area.sound_name)
