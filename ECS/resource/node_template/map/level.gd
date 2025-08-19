## 地图层级系统 - 静态地图中的单个层级管理
## 该类管理静态地图中的单个层级，负责瓦片地图图层的加载和协调、预设实体的初始化管理
## 相机边界的限制设置、房间碰撞体的组织
## 主要功能：异步加载瓦片图层和多边形瓦片、监控预设实体的初始化状态、提供相机限制的边界信息
## 设计特点：基于信号的异步加载机制、统计驱动的完成度检测、灵活的组件依赖管理
## 使用场景：多层建筑的楼层划分、地下城的区域分割、大型地图的区块管理
## [br][b]编辑者:[/b] Sora
class_name Level
extends Node2D

#region 层级信号

## 层级完全加载信号
## 当前层级的所有瓦片图层加载完毕后发出
signal level_fully_loaded

## 层级实体初始化完成信号
## 当前层级的所有预设实体初始化完毕后发出
signal level_entity_fully_initialize

#endregion

#region 层级组件

@export var is_need_fog: bool

@export_group("依赖")
## 相机限制区域
## 用于限制玩家在该层级中的相机边界，类型为 [Control]
@export var camera_limit: Control

## 房间碰撞体集合
## 包含该层级所有房间和区域的碰撞体信息，类型为 [Node2D]
## 只有在房间碰撞体内，才会显示房间内的实体，房间碰撞体外的实体不会显示，但会保持活动。
@export var rooms: Rooms

## 层级对象池
## 用于管理该层级中的临时实体，玩家离开当前层级后会将该层级中的临时实体统一销毁
@export var level_object_pool: Node2D

## 层级迷雾
## 用于管理该层级中的迷雾，类型为 [Fog]
## 用于实现一些恐怖效果，但可以选择关闭
@export var level_fog: Fog

## 所属静态地图
## 指向拥有此层级的静态地图实例，类型为 [StaticMap]
var static_map: StaticMap

## 本层级内的传送点
## 存储该层级中所有传送点的引用
var transport_point_list: Dictionary[StringName, TransportPoint] = {}

#endregion

#region 瓦片图层统计

## 瓦片图层总数
## 当前层级中瓦片地图的总数量
var layers_count = 0

## 已加载瓦片图层数
## 已完成加载的瓦片图层数量
var layers_loaded_count = 0

#endregion

#region 实体统计

## 预设实体总数
## 当前层级中预定义实体的总数量
var entity_count = 0

## 已初始化实体数
## 已完成初始化的预设实体数量
var entity_loaded_count = 0

#endregion

# 进入场景树: 对接瓦片的加载逻辑和预定义实体的初始化监听逻辑
func _enter_tree() -> void:
	for element in get_children():
		if element is TileMapLayer or element is PolygonTile:
			element.ready.connect(_on_layer_ready, CONNECT_DEFERRED)
			layers_count += 1
		elif element is FixedEntity:
			element.initialize_complete.connect(_on_entity_initialize)
			element.is_entity_origin_exist = true
			entity_count += 1
		elif element is TransportPoint:
			if element.enable_export_to_map:
				static_map.exported_transport_points[element.transport_point_key] = element
			transport_point_list[element.transport_point_key] = element
			element.initialize_complete.connect(_on_entity_initialize)
			element.is_entity_origin_exist = true
			entity_count += 1
	_check_all_layers_loaded()

func _on_layer_ready():
	layers_loaded_count += 1
	_check_all_layers_loaded()

func _on_entity_initialize():
	entity_loaded_count += 1
	_check_all_entity_initialize()

func _check_all_layers_loaded():
	if layers_loaded_count == layers_count:
		level_fully_loaded.emit()


func _check_all_entity_initialize():
	if entity_loaded_count == entity_count:
		level_entity_fully_initialize.emit()

func _late_initialize():
	if !is_need_fog:
		level_fog.hide()
	level_fog._initialize()
	rooms._initialize()

func get_camera_limit() -> Dictionary:
	var limit_dict = {}
	var rect = camera_limit.get_global_rect()
	limit_dict["camera_top"] = rect.position.y
	limit_dict["camera_left"] = rect.position.x
	limit_dict["camera_right"] = rect.end.x
	limit_dict["camera_bottom"] = rect.end.y
	return limit_dict

#region :存档系统:
func _save_as(_data: SavedDataFile) -> Dictionary:
	var levels_result = {}
	for element in get_children():
		if element.has_method("_save_as"):
			levels_result.merge(element._save_as(_data))
	return { name:levels_result }

#endregion

#region :层级碰撞导航统一管理:

## 楼层ID标识
## 用于标识当前楼层的唯一ID，通常从0开始递增
@export var level_id: int = 0

## 碰撞导航启用状态
## 记录当前楼层的碰撞检测和导航是否启用
var collision_navigation_enabled: bool = true

# 简化版本：只记录节点的禁用状态，不修改layer/mask

## 简化版本：不保存状态，只标记已初始化
func initialize_collision_navigation_states():
	print("=== 楼层 ", level_id, " (", name, ") 碰撞导航已初始化 ===")
	collision_navigation_enabled = true

## 递归启用该楼层下所有子节点的碰撞检测和导航功能
func enable_all_collision_navigation():
	print("=== 开始启用楼层 ", level_id, " (", name, ") 的碰撞和导航 ===")
	_process_all_collision_navigation_recursive(self, true)
	show()
	collision_navigation_enabled = true
	print("=== 完成启用楼层 ", level_id, " (", name, ") 的碰撞和导航 ===")

## 递归禁用该楼层下所有子节点的碰撞检测和导航功能，防止跨层级干扰
func disable_all_collision_navigation():
	print("=== 开始禁用楼层 ", level_id, " (", name, ") 的碰撞和导航 ===")
	_process_all_collision_navigation_recursive(self, false)
	hide()
	collision_navigation_enabled = false
	print("=== 完成禁用楼层 ", level_id, " (", name, ") 的碰撞和导航 ===")

## 检查楼层碰撞导航状态
## [br][br][b]返回:[/b] [bool] true表示已启用，false表示已禁用
func is_collision_navigation_enabled() -> bool:
	return collision_navigation_enabled

# 已删除状态保存函数，使用简化版本

## 递归处理所有碰撞和导航节点
## [param node]: 当前处理的节点
## [param enabled]: true为启用，false为禁用
func _process_all_collision_navigation_recursive(node: Node, enabled: bool):
	var action = "启用" if enabled else "禁用"
	print("正在处理节点: ", node.name, " (", node.get_class(), ") - ", action)
	
	# 跳过Level节点本身，只处理子节点
	if node != self:
		# 处理物理碰撞体
		if node is CharacterBody2D or node is RigidBody2D or node is StaticBody2D:
			print("  -> 发现物理碰撞体: ", node.name)
			_process_physics_body(node, enabled)
		
		# 处理Area2D
		elif node is Area2D:
			print("  -> 发现Area2D: ", node.name)
			_process_area2d(node, enabled)
		
		# 处理碰撞形状
		elif node is CollisionShape2D or node is CollisionPolygon2D:
			print("  -> 发现碰撞形状: ", node.name)
			_process_collision_shape(node, enabled)
		
		# 处理瓦片地图层
		elif node is TileMapLayer:
			print("  -> 发现瓦片地图层: ", node.name)
			_process_tilemap_layer(node, enabled)
		
		# 处理导航组件
		elif node is NavigationRegion2D:
			print("  -> 发现导航区域: ", node.name)
			_process_navigation_region(node, enabled)
		elif node is NavigationAgent2D:
			print("  -> 发现导航代理: ", node.name)
			_process_navigation_agent(node, enabled)
		elif node is NavigationObstacle2D:
			print("  -> 发现导航障碍物: ", node.name)
			_process_navigation_obstacle(node, enabled)
		else:
			# 如果不是目标类型，简单记录
			if node.get_child_count() == 0:  # 只记录叶子节点，避免太多输出
				print("  -> 跳过非目标节点: ", node.name, " (", node.get_class(), ")")
	
	# 递归处理所有子节点
	for child in node.get_children():
		_process_all_collision_navigation_recursive(child, enabled)

## 处理物理刚体：通过禁用碰撞形状而不是修改layer/mask
## [param node]: 节点
## [param enabled]: true为启用，false为禁用
func _process_physics_body(node: Node, enabled: bool):
	if node is CharacterBody2D or node is RigidBody2D or node is StaticBody2D:
		# 查找并处理所有碰撞形状子节点
		for child in node.get_children():
			if child is CollisionShape2D or child is CollisionPolygon2D:
				child.disabled = !enabled
				if enabled:
					print("启用物理体碰撞形状: ", node.name, "/", child.name)
				else:
					print("禁用物理体碰撞形状: ", node.name, "/", child.name)

## 处理Area2D：只禁用监听功能，不修改layer/mask
## [param area]: Area2D节点
## [param enabled]: true为启用，false为禁用
func _process_area2d(area: Area2D, enabled: bool):
	if enabled:
		area.monitoring = true
		area.monitorable = true
		print("启用Area2D: ", area.name, " monitoring=true monitorable=true")
	else:
		area.monitoring = false
		area.monitorable = false
		print("禁用Area2D: ", area.name, " monitoring=false monitorable=false")

## 处理碰撞形状节点
## [param shape]: CollisionShape2D或CollisionPolygon2D节点
## [param enabled]: true为启用，false为禁用
func _process_collision_shape(shape: Node, enabled: bool):
	if shape is CollisionShape2D or shape is CollisionPolygon2D:
		shape.disabled = !enabled
		if enabled:
			print("启用碰撞形状: ", shape.name)
		else:
			print("禁用碰撞形状: ", shape.name)

## 处理瓦片地图层
## [param tilemap]: TileMapLayer节点
## [param enabled]: true为启用，false为禁用
func _process_tilemap_layer(tilemap: TileMapLayer, enabled: bool):
	tilemap.enabled = enabled
	if enabled:
		print("启用瓦片地图层: ", tilemap.name)
	else:
		print("禁用瓦片地图层: ", tilemap.name)

## 处理导航区域
## [param region]: NavigationRegion2D节点
## [param enabled]: true为启用，false为禁用
func _process_navigation_region(region: NavigationRegion2D, enabled: bool):
	region.enabled = enabled
	if enabled:
		print("启用导航区域: ", region.name)
	else:
		print("禁用导航区域: ", region.name)

## 处理导航代理
## [param agent]: NavigationAgent2D节点
## [param enabled]: true为启用，false为禁用
func _process_navigation_agent(agent: NavigationAgent2D, enabled: bool):
	if enabled:
		agent.process_mode = Node.PROCESS_MODE_INHERIT
		agent.avoidance_enabled = true
	else:
		agent.process_mode = Node.PROCESS_MODE_DISABLED
		agent.avoidance_enabled = false
		# 停止当前导航行为
		var parent_node = agent.get_parent()
		if parent_node is Node2D:
			agent.target_position = parent_node.global_position

## 处理导航障碍物
## [param obstacle]: NavigationObstacle2D节点
## [param enabled]: true为启用，false为禁用
func _process_navigation_obstacle(obstacle: NavigationObstacle2D, enabled: bool):
	if enabled:
		obstacle.process_mode = Node.PROCESS_MODE_INHERIT
		obstacle.avoidance_enabled = true
		print("启用导航障碍物: ", obstacle.name)
	else:
		obstacle.process_mode = Node.PROCESS_MODE_DISABLED
		obstacle.avoidance_enabled = false
		print("禁用导航障碍物: ", obstacle.name)

## 获取碰撞导航状态信息
## [br][br][b]返回:[/b] [Dictionary] 返回楼层的碰撞导航状态信息
func get_collision_navigation_info() -> Dictionary:
	return {
		"level_id": level_id,
		"collision_enabled": collision_navigation_enabled
	}

# 简化版本已完成，不再需要额外的测试方法

#endregion
