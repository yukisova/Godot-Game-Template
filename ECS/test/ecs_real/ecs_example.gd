## ECS架构使用示例
## 展示如何使用SparseSet和ComponentSparseSet构建高效的ECS系统
## 包含完整的组件定义、系统实现和使用演示
## [br][b]编辑者:[/b] Sora

extends Node

# 导入必要的类
# 注意：在实际项目中，这些类应该放在适当的目录结构中
# 这里为了演示目的简化了路径
const SparseSet = preload("sparse_set.gd")
const ComponentSparseSet = preload("component_sparse_set.gd")

# ============================================
# 组件定义（纯数据结构）
# ============================================

class PositionComponent:
	var x: float
	var y: float
	
	func _init(_x: float = 0, _y: float = 0):
		x = _x
		y = _y
	
	func _to_string() -> String:
		return "Position(%.2f, %.2f)" % [x, y]

class VelocityComponent:
	var dx: float
	var dy: float
	
	func _init(_dx: float = 0, _dy: float = 0):
		dx = _dx
		dy = _dy
	
	func _to_string() -> String:
		return "Velocity(%.2f, %.2f)" % [dx, dy]

class HealthComponent:
	var current: int
	var maximum: int
	
	func _init(_max: int = 100):
		maximum = _max
		current = _max
	
	func _to_string() -> String:
		return "Health(%d/%d)" % [current, maximum]

class RenderComponent:
	var sprite_path: String
	var color: Color
	var visible: bool
	
	func _init(_sprite_path: String = "", _color: Color = Color.WHITE):
		sprite_path = _sprite_path
		color = _color
		visible = true
	
	func _to_string() -> String:
		return "Render(%s, %s)" % [sprite_path, color]

# ============================================
# 简化的World管理器
# ============================================

class SimpleECSWorld:
	var next_entity_id: int = 0
	var component_pools: Dictionary = {}
	var entity_archetypes: Dictionary = {}  # entity_id -> archetype_id
	
	func create_entity() -> int:
		var entity_id = next_entity_id
		next_entity_id += 1
		return entity_id
	
	func add_component(entity_id: int, component_type: String, component: Variant) -> bool:
		var pool = get_or_create_pool(component_type)
		return pool.add_component(entity_id, component)
	
	func get_component(entity_id: int, component_type: String) -> Variant:
		var pool = component_pools.get(component_type)
		if pool == null:
			return null
		return pool.get_component(entity_id)
	
	func has_component(entity_id: int, component_type: String) -> bool:
		var pool = component_pools.get(component_type)
		if pool == null:
			return false
		return pool.contains(entity_id)
	
	func remove_component(entity_id: int, component_type: String) -> bool:
		var pool = component_pools.get(component_type)
		if pool == null:
			return false
		return pool.remove_component(entity_id)
	
	func get_or_create_pool(component_type: String) -> ComponentSparseSet:
		if not component_pools.has(component_type):
			component_pools[component_type] = ComponentSparseSet.new(component_type)
		return component_pools[component_type]
	
	# 查询具有指定组件的所有实体
	func query_entities(required_components: Array[String]) -> Array[int]:
		if required_components.is_empty():
			return []
		
		# 找到最小的组件集合作为基础
		var smallest_pool: ComponentSparseSet = null
		var min_size = INF
		
		for component_type in required_components:
			var pool = component_pools.get(component_type)
			if pool == null:
				return []  # 如果任何组件类型不存在，返回空结果
			
			if pool.get_size() < min_size:
				min_size = pool.get_size()
				smallest_pool = pool
		
		# 基于最小集合进行过滤
		var result: Array[int] = []
		var entities = smallest_pool.get_entities()
		
		for entity_id in entities:
			var has_all_components = true
			for component_type in required_components:
				if not has_component(entity_id, component_type):
					has_all_components = false
					break
			
			if has_all_components:
				result.append(entity_id)
		
		return result
	
	func destroy_entity(entity_id: int):
		# 从所有组件池中移除该实体
		for pool in component_pools.values():
			pool.remove_component(entity_id)
		
		entity_archetypes.erase(entity_id)
	
	func print_world_info():
		print("=== ECS World Info ===")
		print("Total entities: %d" % next_entity_id)
		print("Component pools:")
		for type in component_pools.keys():
			var pool = component_pools[type]
			print("  %s: %d entities" % [type, pool.get_size()])
		print("======================")

# ============================================
# 系统定义（纯逻辑处理）
# ============================================

class MovementSystem:
	func update(world: SimpleECSWorld, delta: float):
		# 查询同时拥有位置和速度组件的实体
		var entities = world.query_entities(["PositionComponent", "VelocityComponent"])
		
		for entity_id in entities:
			var pos = world.get_component(entity_id, "PositionComponent")
			var vel = world.get_component(entity_id, "VelocityComponent")
			
			# 更新位置
			pos.x += vel.dx * delta
			pos.y += vel.dy * delta

class HealthSystem:
	func update(world: SimpleECSWorld, delta: float):
		var entities = world.query_entities(["HealthComponent"])
		
		for entity_id in entities:
			var health = world.get_component(entity_id, "HealthComponent")
			
			# 示例：随时间缓慢恢复生命值
			if health.current < health.maximum:
				health.current = min(health.maximum, health.current + int(10 * delta))

class RenderSystem:
	func update(world: SimpleECSWorld, _delta: float):
		# 查询需要渲染的实体
		var entities = world.query_entities(["PositionComponent", "RenderComponent"])
		
		for entity_id in entities:
			var pos = world.get_component(entity_id, "PositionComponent")
			var render = world.get_component(entity_id, "RenderComponent")
			
			if render.visible:
				# 这里应该调用实际的渲染代码
				# 例如：更新Godot节点的位置
				print("Rendering entity_%d at (%.1f, %.1f) with %s" % [entity_id, pos.x, pos.y, render.sprite_path])

# ============================================
# 演示代码
# ============================================

var world: SimpleECSWorld
var movement_system: MovementSystem
var health_system: HealthSystem
var render_system: RenderSystem

func _ready():
	print("开始ECS架构演示...")
	
	# 初始化世界和系统
	world = SimpleECSWorld.new()
	movement_system = MovementSystem.new()
	health_system = HealthSystem.new()
	render_system = RenderSystem.new()
	
	# 创建一些示例实体
	create_example_entities()
	
	# 显示初始状态
	print_entity_states()
	
	# 运行几次更新循环
	for i in range(5):
		print("\n--- 更新循环 %d ---" % (i + 1))
		update_systems(1.0)  # 假设delta为1.0秒
		print_entity_states()
	
	# 展示查询功能
	demonstrate_queries()
	
	# 展示性能测试
	performance_test()

func create_example_entities():
	print("\n创建示例实体...")
	
	# 实体1：移动的玩家角色
	var player = world.create_entity()
	world.add_component(player, "PositionComponent", PositionComponent.new(0, 0))
	world.add_component(player, "VelocityComponent", VelocityComponent.new(5, 3))
	world.add_component(player, "HealthComponent", HealthComponent.new(80))
	world.add_component(player, "RenderComponent", RenderComponent.new("player.png", Color.BLUE))
	print("创建玩家实体: %d" % player)
	
	# 实体2：静态的NPC
	var npc = world.create_entity()
	world.add_component(npc, "PositionComponent", PositionComponent.new(10, 5))
	world.add_component(npc, "HealthComponent", HealthComponent.new(60))
	world.add_component(npc, "RenderComponent", RenderComponent.new("npc.png", Color.GREEN))
	print("创建NPC实体: %d" % npc)
	
	# 实体3：移动的敌人
	var enemy = world.create_entity()
	world.add_component(enemy, "PositionComponent", PositionComponent.new(-5, 2))
	world.add_component(enemy, "VelocityComponent", VelocityComponent.new(-2, 1))
	world.add_component(enemy, "HealthComponent", HealthComponent.new(40))
	world.add_component(enemy, "RenderComponent", RenderComponent.new("enemy.png", Color.RED))
	print("创建敌人实体: %d" % enemy)
	
	# 实体4：只有位置的标记点
	var marker = world.create_entity()
	world.add_component(marker, "PositionComponent", PositionComponent.new(100, 100))
	print("创建标记点实体: %d" % marker)

func update_systems(delta: float):
	movement_system.update(world, delta)
	health_system.update(world, delta)
	# 注释掉渲染系统以减少输出
	# render_system.update(world, delta)

func print_entity_states():
	print("\n当前实体状态:")
	
	# 获取所有有位置组件的实体
	var entities_with_pos = world.query_entities(["PositionComponent"])
	
	for entity_id in entities_with_pos:
		var components = []
		
		var pos = world.get_component(entity_id, "PositionComponent")
		if pos:
			components.append(str(pos))
		
		var vel = world.get_component(entity_id, "VelocityComponent")
		if vel:
			components.append(str(vel))
		
		var health = world.get_component(entity_id, "HealthComponent")
		if health:
			components.append(str(health))
		
		print("  Entity_%d: %s" % [entity_id, ", ".join(components)])

func demonstrate_queries():
	print("\n=== 查询系统演示 ===")
	
	# 查询移动实体
	var moving_entities = world.query_entities(["PositionComponent", "VelocityComponent"])
	print("移动实体: %s" % str(moving_entities))
	
	# 查询有生命值的实体
	var living_entities = world.query_entities(["HealthComponent"])
	print("有生命值的实体: %s" % str(living_entities))
	
	# 查询可渲染实体
	var renderable_entities = world.query_entities(["PositionComponent", "RenderComponent"])
	print("可渲染实体: %s" % str(renderable_entities))
	
	# 查询复杂组合
	var complex_entities = world.query_entities(["PositionComponent", "VelocityComponent", "HealthComponent"])
	print("复杂实体（位置+速度+生命值）: %s" % str(complex_entities))

func performance_test():
	print("\n=== 性能测试 ===")
	
	var test_world = SimpleECSWorld.new()
	var entity_count = 10000
	
	# 创建大量实体
	var start_time = Time.get_ticks_msec()
	
	for i in range(entity_count):
		var entity = test_world.create_entity()
		test_world.add_component(entity, "PositionComponent", PositionComponent.new(randf() * 1000, randf() * 1000))
		if i % 2 == 0:  # 50%的实体有速度组件
			test_world.add_component(entity, "VelocityComponent", VelocityComponent.new(randf() * 10 - 5, randf() * 10 - 5))
		if i % 3 == 0:  # 33%的实体有生命值组件
			test_world.add_component(entity, "HealthComponent", HealthComponent.new(randi() % 100 + 50))
	
	var creation_time = Time.get_ticks_msec() - start_time
	print("创建 %d 个实体耗时: %d ms" % [entity_count, creation_time])
	
	# 查询性能测试
	start_time = Time.get_ticks_msec()
	
	var moving_entities = test_world.query_entities(["PositionComponent", "VelocityComponent"])
	var query_time = Time.get_ticks_msec() - start_time
	print("查询移动实体耗时: %d ms, 找到 %d 个实体" % [query_time, moving_entities.size()])
	
	# 更新性能测试
	var test_movement_system = MovementSystem.new()
	start_time = Time.get_ticks_msec()
	
	for i in range(100):  # 模拟100次更新
		test_movement_system.update(test_world, 0.016)  # 60fps
	
	var update_time = Time.get_ticks_msec() - start_time
	print("100次移动系统更新耗时: %d ms" % update_time)
	
	# 显示内存使用情况
	test_world.print_world_info()
	
	# 显示组件池内存信息
	var pos_pool = test_world.component_pools.get("PositionComponent")
	if pos_pool:
		var memory_info = pos_pool.get_memory_info()
		print("位置组件池内存效率: %.2f%%" % (memory_info.memory_efficiency * 100))

func _exit_tree():
	print("\nECS演示结束")
