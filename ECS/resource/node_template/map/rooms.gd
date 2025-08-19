## 房间管理系统 - 管理地图中不同房间的实体分组和可见性控制
## 该系统负责实体在房间间的移动检测、房间分组管理以及基于房间的可见性控制，实现房间级别的实体隔离
## 核心功能：房间进入/离开检测、实体房间归属管理、房间切换可见性控制、跨房间实体检测
## 应用场景：多房间建筑、区域分层显示、实体空间管理、性能优化（只显示当前房间实体）
## 架构设计：基于Area2D的碰撞检测，支持动态房间管理和实体可见性控制
## [br][b]编辑者:[/b] Sora
class_name Rooms
extends Node2D

## 房间切换信号
## 当玩家实体进入新房间时发出，用于触发房间切换逻辑
signal room_changed(room_index: int)

## 房间实体列表
## 二维数组，索引为房间ID，值为该房间内的所有实体列表，用于房间级别的实体管理
var room_list: Array[Array] = []

## 初始化房间系统—设置房间区域监听和信号连接
func _initialize():
	for room: Area2D in get_children():
		room_list.append([])
		var room_index = room.get_index()
		room.body_entered.connect(_on_room_body_entered.bind(room_index))
		room.body_exited.connect(_on_room_body_exited.bind(room_index))
	room_changed.connect(_on_room_changed)

## 处理实体进入房间—将实体添加到对应房间列表并触发房间切换
## [param body]: 进入房间的碰撞体
## [param room_index]: 目标房间索引
func _on_room_body_entered(body: Node2D, room_index: int):
	if not _is_valid_room_index(room_index) or not body.get_parent() is FixedEntity:
		return
		
	var entity: FixedEntity = body.get_parent()
	
	# 避免重复添加
	if entity.room_index == room_index:
		return
		
	# 从旧房间移除（如果存在）
	_remove_entity_from_room(entity, entity.room_index)
	
	# 添加到新房间
	entity.room_index = room_index
	room_list[room_index].append(entity)
	
	# 玩家进入时触发房间切换
	if body.is_in_group("player"):
		room_changed.emit(room_index)
	
	print("实体 %s 进入房间 %d" % [entity.name, room_index])

## 处理实体离开房间—从房间列表中移除实体
## [param body]: 离开房间的碰撞体
## [param room_index]: 离开的房间索引
func _on_room_body_exited(body: Node2D, room_index: int):
	if not _is_valid_room_index(room_index) or not body.get_parent() is FixedEntity:
		return
		
	var entity: FixedEntity = body.get_parent()
	_remove_entity_from_room(entity, room_index)
	
	print("实体 %s 离开房间 %d" % [entity.name, room_index])

## 检查两个实体是否在不同房间—用于跨房间交互检测
## [param entity_a]: 第一个实体
## [param entity_b]: 第二个实体
func check_entities_in_different_rooms(entity_a: FixedEntity, entity_b: FixedEntity) -> bool:
	if not entity_a or not entity_b:
		return false
		
	var room_a = entity_a.room_index
	var room_b = entity_b.room_index
	
	# 如果任一实体不在房间中，或在同一房间，则返回false
	if room_a == -1 or room_b == -1 or room_a == room_b:
		return false
	
	# 检查实体是否确实在各自声明的房间中
	return _is_valid_room_index(room_a) and _is_valid_room_index(room_b) and \
		   room_list[room_a].has(entity_a) and room_list[room_b].has(entity_b)

## 处理房间切换—控制不同房间实体的可见性
## [param new_room_index]: 新房间索引
func _on_room_changed(new_room_index: int):
	if not _is_valid_room_index(new_room_index):
		return
	
	# 隐藏所有房间的实体
	for room_entities in room_list:
		for room_entity in room_entities:
			if room_entity and is_instance_valid(room_entity):
				room_entity.visible = false
	
	# 显示当前房间的实体
	for room_entity in room_list[new_room_index]:
		if room_entity and is_instance_valid(room_entity):
			room_entity.visible = true

## 获取指定房间的实体列表—返回房间内所有实体的副本
## [param room_index]: 房间索引
func get_room_entities(room_index: int) -> Array:
	if not _is_valid_room_index(room_index):
		return []
	return room_list[room_index].duplicate()

## 获取实体所在房间索引—返回实体当前所在的房间ID
## [param entity]: 目标实体
func get_entity_room_index(entity: FixedEntity) -> int:
	if not entity:
		return -1
	return entity.room_index

## 获取房间总数—返回当前管理的房间数量
func get_room_count() -> int:
	return room_list.size()

## 验证房间索引有效性—检查房间索引是否在有效范围内
## [param room_index]: 要验证的房间索引
func _is_valid_room_index(room_index: int) -> bool:
	return room_index >= 0 and room_index < room_list.size()

## 从指定房间移除实体—安全地从房间列表中移除实体
## [param entity]: 要移除的实体
## [param room_index]: 房间索引
func _remove_entity_from_room(entity: FixedEntity, room_index: int):
	if not _is_valid_room_index(room_index) or not entity:
		return
		
	var entity_index = room_list[room_index].find(entity)
	if entity_index != -1:
		room_list[room_index].remove_at(entity_index)