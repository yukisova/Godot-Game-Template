## 近战攻击判定盒
## 与远程攻击不同，近战攻击判定盒的持续时间非常短
## 为了方便起见，攻击时采用激活的方式进行设计, 而非原生的持续方式
@tool
class_name HitboxMelee
extends IHitbox

@export var hit_box_resource: Array[BoxCollisionResource]:
	set(v):
		hit_box_resource = v
		# 编辑器中实时更新视野显示
		if Engine.is_editor_hint():
			initialize_collision()

var hit_targets: Array[Hurtbox] = []
var is_hitting: bool = false

func _enter_tree() -> void:
	super()
	area_entered.connect(_hurt_target_entered)
	area_exited.connect(_hurt_target_exited)
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED

func _ready() -> void:
	if Engine.is_editor_hint(): return
	initialize_collision()

## 释放
func _release(direction: Vector2):
	rotation = direction.angle()
	show()
	process_mode = Node.PROCESS_MODE_INHERIT
	is_hitting = true
	_start_hitting()

## 重置
func _reset():
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
	is_hitting = false

func _start_hitting():
	for i in hit_targets:
		print("攻击到了", i)
		i.just_suffered.emit(get_hit_effects())

func _hurt_target_entered(area: Area2D):
	if area is Hurtbox:
		if area.c_collision.component_owner != c_collision.component_owner:
			hit_targets.append(area)
			if is_hitting:
				_start_hitting()


func _hurt_target_exited(area: Area2D):
	if area is Hurtbox:
		hit_targets.erase(area)

func initialize_collision():
	# 清理现有的碰撞形状
	for child in get_children():
		child.queue_free()
	
	# 根据配置生成新的碰撞形状
	for resource in hit_box_resource:
		if resource == null: 
			continue
		
		match resource.sight_collision_type:
			BoxCollisionResource.SightCollisionType.Sector:
				add_child(SoraEvent.sector_generate(resource))
			BoxCollisionResource.SightCollisionType.Capsule:
				add_child(SoraEvent.circle_generate(resource))
			BoxCollisionResource.SightCollisionType.Rectangle:
				add_child(SoraEvent.rectangle_generate(resource))
