## 视觉检测盒 - 实现生物角色的视觉感知系统
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
##
## 架构设计：
## - 继承自 [BoxCollision] 基类
## - 基于 [SightCollisionResource] 的配置系统
## - 使用 [annotation @tool] 支持编辑器预览
## - 通过信号系统通知目标状态变化
##
## [br][b]编辑者:[/b] Sora
@tool
class_name SightBox
extends BoxCollision

## 目标发现信号
## 
## 当视野范围内首次出现目标时发出。
signal target_noticed

## 目标丢失信号
## 
## 当视野范围内的所有目标都离开时发出。
signal target_losed

## 视野配置资源数组
## 
## 定义不同形状和参数的视野检测区域，类型为 [Array] of [SightCollisionResource]。
@export var sight_box_resource: Array[SightCollisionResource]:
	set(v):
		sight_box_resource = v
		# 编辑器中实时更新视野显示
		if Engine.is_editor_hint():
			initialize_collision()

## 追踪目标群组名称
## 
## 定义需要重点关注和追踪的目标群组，类型为 [Array] of [StringName]。
@export var chase_target_group_name: Array[StringName]

## 当前视野内的目标列表
## 存储所有在视野范围内的目标实体，类型为 [Array] of [Node2D]。
var sight_target: Array[Node2D]

## 待定视野内的目标列表
## 存储位于sight_box范围内但因为障碍物判定为不可见的目标实体，会在每一帧动态生成射线进行验证，如果验证通过，则加入到sight_target列表中
var await_sight_target: Array[Node2D]

## 目标最后位置
## 
## 记录目标离开视野时的最后已知位置，用于AI寻路。类型为 [Vector2]。
var sight_target_last_position: Vector2

func get_target_direction() -> Vector2:
	if sight_target.is_empty(): return Vector2.ZERO
	return c_collision.component_body.global_position.direction_to(sight_target[-1].global_position).normalized()

func get_target_position() -> Vector2:
	if sight_target.is_empty(): return Vector2.INF
	return sight_target[-1].global_position

func _enter_tree() -> void:
	box_collision_name = CCollisionBox.BoxCollisionName.SIGHT

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
func _initialize() -> void:
	# 初始化碰撞检测形状
	initialize_collision()

	# 启用朝向旋转
	enable_rotate_by_award = true
	
	# 连接检测信号
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _fixed_update(_delta: float):
	# 限制验证频率，避免每帧都进行射线检测（性能优化）
	if not await_sight_target.is_empty():
		validate_awaiting_targets()
	if not sight_target.is_empty():
		validate_sight_targets()
 
## 当目标进入视野范围时触发。
## [param body]: 进入视野的刚体，类型为 [Node2D]
func _on_body_entered(body: Node2D):
	var is_target = false
	
	# 检查是否为关注的目标群组
	for group_name in chase_target_group_name:
		if body.is_in_group(group_name):
			is_target = true
			break

	if is_target:
		# 使用射线检测验证目标是否真正可见（没有被障碍物遮挡）
		if can_see_target(body):
			# 目标可见，直接加入视野列表
			if sight_target.is_empty():
				target_noticed.emit()
			sight_target.append(body)
			print("视觉检测: 目标可见，加入视野列表 -> ", body.get_parent().name if body.get_parent() else body.name)
		else:
			# 目标被遮挡，加入待定列表，稍后进行验证
			if not await_sight_target.has(body):
				await_sight_target.append(body)
				print("视觉检测: 目标暂时被遮挡，加入待定列表 -> ", body.get_parent().name if body.get_parent() else body.name)

## 目标离开视野处理
## 
## 当目标离开视野范围时触发。
## [param body]: 离开视野的刚体，类型为 [Node2D]
func _on_body_exited(body: Node2D):
	var is_target = false
	
	# 检查是否为关注的目标群组
	for group_name in chase_target_group_name:
		if body.is_in_group(group_name):
			is_target = true
			break
	
	if is_target:
		# 从视野目标列表中移除
		var was_in_sight = sight_target.has(body)
		sight_target.erase(body)
		
		# 从待定目标列表中移除
		await_sight_target.erase(body)
		
		if was_in_sight:
			print("视觉检测: 目标离开视野 -> ", body.get_parent().name if body.get_parent() else body.name)
			print("当前视野内目标: ", sight_target.map(func(v): return v.get_parent().name if v.get_parent() else v.name))
			
			# 如果所有目标都离开了，记录最后位置并发出丢失信号
			if sight_target.is_empty():
				sight_target_last_position = body.global_position
				target_losed.emit()
		else:
			print("视觉检测: 待定目标离开检测区域 -> ", body.get_parent().name if body.get_parent() else body.name)

#region 射线检测系统

## 射线检测：验证目标是否可见
## 
## 使用PhysicsRayQueryParameters2D进行射线检测，判断从检测源到目标之间是否有障碍物遮挡。
## [param target]: 要检测的目标节点，类型为 [Node2D]
## [return]: 如果目标可见返回true，被遮挡返回false，类型为 [bool]
func can_see_target(target: Node2D) -> bool:
	if not target or not c_collision or not c_collision.component_body:
		return false
	
	# 获取射线检测的起始位置（视觉检测盒的中心位置）
	var ray_start = c_collision.component_body.global_position
	# 获取目标位置
	var ray_end = target.global_position
	
	# 如果目标距离太近，认为可见（避免自身检测问题）
	if ray_start.distance_to(ray_end) < 10.0:
		return true
	
	# 创建射线查询参数
	var ray_query = PhysicsRayQueryParameters2D.create(
		ray_start,
		ray_end,
		get_obstacle_collision_mask(),
		get_exclusion_array(target)
	)
	# 执行射线检测
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(ray_query)
	
	# 如果没有碰撞到任何物体，说明视线畅通
	if result.is_empty():
		return true
	
	# 检查碰撞到的物体是否为障碍物
	var hit_body = result.get("collider")
	if hit_body and is_obstacle(hit_body):
		return false
	
	return true

## 获取障碍物碰撞掩码
## 
## 返回用于射线检测的碰撞掩码，用于识别哪些层级的物体被视为障碍物。
## [return]: 碰撞掩码值，类型为 [int]
func get_obstacle_collision_mask() -> int:
	# 这里可以根据项目需求设置具体的碰撞层
	# 例如：墙体、障碍物等的碰撞层
	# 返回值示例：层1（墙体）+ 层3（障碍物）= 1 + 4 = 5
	return Main.PhysicsLayer.Wall

## 获取排除检测的物体数组
## 
## 返回在射线检测中需要排除的物体数组（如自身、目标等）。
## [param target]: 目标物体，类型为 [Node2D]
## [return]: 排除物体数组，类型为 [Array]
func get_exclusion_array(target: Node2D) -> Array:
	var exclusions = []
	
	# 排除自身相关的物体
	if c_collision and c_collision.component_body:
		exclusions.append(c_collision.component_body)
	
	# 排除目标本身（我们要检测的是到达目标的路径是否畅通）
	exclusions.append(target)
	
	# 如果有父节点，也排除父节点
	if target.get_parent():
		exclusions.append(target.get_parent())
	
	return exclusions

## 判断物体是否为障碍物
## 
## 判断指定的物体是否应该被视为阻挡视线的障碍物。
## [param body]: 要判断的物体，类型为 [Node2D]
## [return]: 如果是障碍物返回true，否则返回false，类型为 [bool]
func is_obstacle(body: Node2D) -> bool:
	# 检查物体是否在障碍物群组中
	if body.is_in_group("obstacle") or body.is_in_group("wall") or body.is_in_group("terrain"):
		return true
	return false

func validate_sight_targets():
	print("视觉检测: 验证视野目标列表")
	print("视野目标列表: ", sight_target.map(func(v): return v.get_parent().name if v.get_parent() else v.name))
	if sight_target.is_empty():
		return
	
	var targets_to_check = sight_target.duplicate()

	for target in targets_to_check:
		if not is_instance_valid(target):
			sight_target.erase(target)
			continue
		
		if not can_see_target(target):
			sight_target.erase(target)
			if sight_target.is_empty():
				target_losed.emit()
			continue

## 验证待定目标列表
## 定期检查await_sight_target列表中的目标是否变为可见状态。
## 应该在_fixed_update中调用此方法。
func validate_awaiting_targets():
	print("视觉检测: 验证待定目标列表")
	print("待定目标列表: ", await_sight_target.map(func(v): return v.get_parent().name if v.get_parent() else v.name))
	if await_sight_target.is_empty():
		return
	
	# 创建副本避免在循环中修改数组
	var targets_to_check = await_sight_target.duplicate()
	
	for target in targets_to_check:
		if not is_instance_valid(target):
			# 目标已被删除，从待定列表中移除
			await_sight_target.erase(target)
			continue
		
		# 重新进行射线检测
		if can_see_target(target):
			# 目标现在可见，加入视野列表
			if sight_target.is_empty():
				target_noticed.emit()
			sight_target.append(target)
			print("视觉检测: 目标可见，加入视野列表 -> ", target.get_parent().name if target.get_parent() else target.name)

#endregion

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
