## @editing: Sora [br]
## @describe: 生物类角色的视线BoxCollisionShape
@tool
class_name SightBox
extends BoxCollision

signal target_noticed ## 视觉组件内出现了信息
signal target_losed ## 

@export var sight_box_resource: Array[SightCollisionResource]:
	set(v):
		sight_box_resource = v
		if Engine.is_editor_hint():
			initialize_collision()
@export var chase_target_group_name: Array[StringName] ## 视觉Collision所重点反应的目标分组名

var sight_target: Array[Node2D]

func initialize_collision():
	for i in get_children():
		i.queue_free()
	for i in sight_box_resource:
		if i == null: continue
		match i.sight_collision_type:
			SightCollisionResource.SightCollisionType.Sector:
				sector_generate(i)
			SightCollisionResource.SightCollisionType.Capsule:
				circle_generate(i)
			SightCollisionResource.SightCollisionType.Rectangle:
				rectangle_generate(i)

func initialize():
	initialize_collision()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D):
	var flag = false
	for i in chase_target_group_name:
		if body.is_in_group(i):
			flag = true
			break
	if flag:
		if sight_target.is_empty():
			target_noticed.emit()
		sight_target.append(body)
		print("看见了目标物品，目前的视角内信息: ", sight_target.map(func(v): return v.get_parent().name))

func _on_body_exited(body: Node2D):
	var flag = false
	for i in chase_target_group_name:
		if body.is_in_group(i):
			flag = true
			break
	if flag:
		sight_target.erase(body)
		print("视线内失去了某个目标，目前的视角内信息: ", sight_target.map(func(v): return v.get_parent().name))
		if sight_target.is_empty():
			target_losed.emit()

#region 碰撞体生成
## 生成扇形, sight_wide为扇形的角度(degree)
func sector_generate(collsion_info: SightCollisionResource):
	var sight_wide = collsion_info.sight_wide
	var sight_range = collsion_info.sight_range
	var sight_offset = collsion_info.sight_offset
	
	var polygonVertex : PackedVector2Array = [Vector2.ZERO]
	for i in range( -sight_wide / 2.0 ,sight_wide / 2.0 + 1 ,1): ## 加一的目的是为了避免缺失5度
		if i % 5 == 0:
			polygonVertex.append(Vector2(sight_range,0).rotated(-deg_to_rad(i)))
	
	var collision = CollisionPolygon2D.new()
	collision.polygon = polygonVertex
	collision.position = sight_offset
	add_child(collision)

func rectangle_generate(collsion_info: SightCollisionResource):
	var sight_wide = collsion_info.sight_wide
	var sight_range = collsion_info.sight_range
	var sight_offset = collsion_info.sight_offset
	
	var shape = RectangleShape2D.new()
	shape.size = Vector2(sight_range, sight_wide)
	
	var collision = CollisionShape2D.new()
	collision.shape = shape
	collision.position = sight_offset
	add_child(collision)

func circle_generate(collsion_info: SightCollisionResource):
	var sight_wide = collsion_info.sight_wide
	var sight_range = collsion_info.sight_range
	var sight_offset = collsion_info.sight_offset
	
	var shape = CapsuleShape2D.new()
	shape.mid_height = sight_wide
	shape.radius = sight_range
	
	var collision = CollisionShape2D.new()
	collision.shape = shape
	collision.position = sight_offset
	add_child(collision)
#endregion
