## @editing: Sora [br]
## @describe: 视觉检测盒 - 实现生物角色的视觉感知系统
## 
## 该类为生物类角色提供视觉检测功能，能够感知视野范围内的目标并触发相应行为。
## 支持多种视野形状（扇形、矩形、胶囊形），可配置检测目标和范围。
## 
## 视觉系统特性：
## - 多形状支持：扇形、矩形、胶囊形视野
## - 目标过滤：基于群组的目标检测过滤
## - 实时检测：持续监控视野范围内的目标变化
## - 位置记录：记录目标最后出现的位置
## - 编辑器集成：在编辑器中实时预览视野范围
## 
## 视野形状类型：
## - 扇形：模拟真实的视觉锥形，适合大多数生物
## - 矩形：简单的矩形检测区域，适合机械单位
## - 胶囊形：椭圆形检测区域，适合特殊的感知需求
## 
## 应用场景：
## - 敌人AI：发现玩家并开始追击
## - 守卫系统：巡逻守卫的视野检测
## - 野生动物：动物的警觉和逃跑行为
## - 监控系统：安全摄像头的检测范围
## - 感知法术：增强角色感知能力的魔法效果
@tool
class_name SightBox
extends BoxCollision

## 目标发现信号
## 当视野范围内首次出现目标时发出
signal target_noticed

## 目标丢失信号
## 当视野范围内的所有目标都离开时发出
signal target_losed

## 视野配置资源数组
## 定义不同形状和参数的视野检测区域
@export var sight_box_resource: Array[SightCollisionResource]:
	set(v):
		sight_box_resource = v
		# 编辑器中实时更新视野显示
		if Engine.is_editor_hint():
			initialize_collision()

## 追踪目标群组名称
## 定义需要重点关注和追踪的目标群组
@export var chase_target_group_name: Array[StringName]

## 当前视野内的目标列表
## 存储所有在视野范围内的目标实体
var sight_target: Array[Node2D]

## 目标最后位置
## 记录目标离开视野时的最后已知位置，用于AI寻路
var sight_target_last_position: Vector2

## 初始化碰撞检测
## 根据配置的视野资源生成对应的碰撞形状
func initialize_collision():
	# 清理现有的碰撞形状
	for child in get_children():
		child.queue_free()
	
	# 根据配置生成新的碰撞形状
	for resource in sight_box_resource:
		if resource == null: 
			continue
		
		match resource.sight_collision_type:
			SightCollisionResource.SightCollisionType.Sector:
				sector_generate(resource)
			SightCollisionResource.SightCollisionType.Capsule:
				circle_generate(resource)
			SightCollisionResource.SightCollisionType.Rectangle:
				rectangle_generate(resource)

## 视觉系统初始化
## 设置碰撞检测和信号连接
func _ready() -> void:
	# 编辑器模式下不执行运行时逻辑
	if Engine.is_editor_hint(): 
		return
	
	# 初始化碰撞检测形状
	initialize_collision()
	
	# 连接检测信号
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

## 目标进入视野处理
## 当目标进入视野范围时触发
## @param body: 进入视野的刚体
func _on_body_entered(body: Node2D):
	var is_target = false
	
	# 检查是否为关注的目标群组
	for group_name in chase_target_group_name:
		if body.is_in_group(group_name):
			is_target = true
			break
	
	if is_target:
		# 如果是第一个发现的目标，发出发现信号
		if sight_target.is_empty():
			target_noticed.emit()
		
		# 添加到目标列表
		sight_target.append(body)
		print("视觉检测: 发现目标 -> ", body.get_parent().name if body.get_parent() else body.name)
		print("当前视野内目标: ", sight_target.map(func(v): return v.get_parent().name if v.get_parent() else v.name))

## 目标离开视野处理
## 当目标离开视野范围时触发
## @param body: 离开视野的刚体
func _on_body_exited(body: Node2D):
	var is_target = false
	
	# 检查是否为关注的目标群组
	for group_name in chase_target_group_name:
		if body.is_in_group(group_name):
			is_target = true
			break
	
	if is_target:
		# 从目标列表中移除
		sight_target.erase(body)
		print("视觉检测: 目标离开视野 -> ", body.get_parent().name if body.get_parent() else body.name)
		print("当前视野内目标: ", sight_target.map(func(v): return v.get_parent().name if v.get_parent() else v.name))
		
		# 如果所有目标都离开了，记录最后位置并发出丢失信号
		if sight_target.is_empty():
			sight_target_last_position = body.global_position
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
