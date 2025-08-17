## 层级对象池 - 实现高效的层级化对象重用机制
##
## 该类为游戏中频繁创建和销毁的对象提供高效的内存管理，专为层级系统设计：
## - 预分配指定数量的对象，避免运行时频繁创建
## - 提供对象的获取和回收接口
## - 自动管理对象的启用/禁用状态
## - 支持对象的状态重置和位置设置
##
## 主要应用场景：
## - 子弹系统：射击游戏中的弹药对象
## - 特效系统：粒子、爆炸、治疗效果等
## - 敌人系统：批量生成的小怪物
## - UI系统：动态创建的界面元素
##
## 对象要求：
## - 可被重用的对象应实现 [method reset] 方法来重置状态
## - 对象应能够正确处理启用/禁用状态切换
## - 对象必须继承自 [TempEntity] 类型
##
## 性能优化：
## - 对象回收时不从场景树中移除，只是禁用
## - 减少场景树变化带来的性能开销
## - 保持对象在场景树中的稳定性
##
## 架构设计：
## - 继承自 [Node2D] 基类
## - 与 [PackedScene] 预制体系统集成
## - 基于 [Array] 的对象管理
## - 通过 [signal despawned] 处理对象回收
##
## [br][b]编辑者:[/b] Sora
class_name LevelObjectPool
extends Node2D

#region 对象池数据

## 对象预制体
## 
## 用于创建对象实例的场景预制体，类型为 [PackedScene]。
var _prefab: PackedScene

## 可用对象列表
## 
## 存储当前未使用的对象实例，类型为 [Array] of [TempEntity]。
var _available: Array[TempEntity] = []

## 活跃对象列表
## 
## 存储当前正在使用的对象实例，类型为 [Array] of [TempEntity]。
var _active: Array[TempEntity] = []

## 当前池大小
## 
## 对象池中当前的总对象数量。
var current_size: int

## 初始池大小
## 
## 对象池初始化时预分配的对象数量。
var initial_size: int

#endregion

#region 初始化

## 对象池构造函数
## 
## [param prefab]: 对象的预制体场景，类型为 [PackedScene]
## [param _initial_size]: 初始预分配的对象数量
func _init(prefab: PackedScene, _initial_size: int):
	_prefab = prefab
	
	# 预分配指定数量的对象
	for i in range(_initial_size):
		var obj = _prefab.instantiate()
		_disable_node(obj)
		_available.append(obj)
		add_child(obj)
		obj.level_object_pool = self
		obj.despawned.connect(despawn)
	
	print("对象池: 初始化完成，预分配 %d 个对象" % _initial_size)
	initial_size = _initial_size
	current_size = _initial_size

#endregion

#region 对象生命周期管理

## 从对象池获取对象
## 
## [param _position]: 对象的初始位置，类型为 [Vector2]
## [param _context]: 对象的初始化上下文数据，类型为 [Dictionary]
## [br][br][b]返回:[/b] [TempEntity] 获取的对象实例
func spawn(_position: Vector2, _context: Dictionary) -> TempEntity:
	var obj: TempEntity

	# 从可用列表中寻找有效对象
	while not _available.is_empty():
		var candidate = _available.pop_back()
		# 检查对象是否仍然有效（未被释放）
		if is_instance_valid(candidate):
			obj = candidate
			break
		else:
			# 如果对象已被释放，从池计数中减去
			current_size -= 1
			print("对象池: 发现已释放的对象，已从池中移除")
	
	# 如果没有找到有效对象，创建新对象
	if obj == null:
		obj = _prefab.instantiate()
		add_child(obj)
		obj.level_object_pool = self
		current_size += 1
		obj.despawned.connect(despawn)
		print("对象池: 创建新对象,当前池大小: %d" % current_size)

	_reset_node(obj, _context, _position)
	_active.append(obj)
	
	return obj

## 回收对象到对象池
## 
## [param obj]: 要回收的对象，类型为 [Node]
func despawn(obj: Node) -> void:
	# 检查对象是否仍然有效
	if not is_instance_valid(obj):
		push_warning("对象池: 尝试回收已释放的对象")
		return
	
	if _active.has(obj):
		_active.erase(obj)
		_disable_node(obj)
		_available.append(obj)
	elif _available.has(obj):
		push_warning("对象池: 对象已在可用列表中，跳过回收")
	else:
		push_warning("对象池: 尝试回收不属于此池的对象，用销毁代替回收")
		# 确保对象不在任何数组中再销毁
		_active.erase(obj)
		_available.erase(obj)
		obj.queue_free()
		current_size -= 1
#endregion

#region 对象状态管理

## 禁用对象
## 
## 将对象设置为不可见和不处理状态，但保持在场景树中以避免频繁的add_child/remove_child操作。
## [param obj]: 要禁用的对象，类型为 [Node]
func _disable_node(obj: Node) -> void:
	obj.process_mode = Node.PROCESS_MODE_DISABLED
	obj.hide()

## 重置对象状态
## 
## 设置对象的位置并调用其重置方法。
## [param obj]: 要重置的对象，类型为 [TempEntity]
## [param _context]: 重置用的上下文数据，类型为 [Dictionary]
## [param _position]: 新的位置，类型为 [Vector2]
func _reset_node(obj: TempEntity, _context: Dictionary, _position: Vector2) -> void:
	obj.main_control.global_position = _position
	obj.reset(_context)
	obj.process_mode = Node.PROCESS_MODE_INHERIT
	obj.show()

#endregion

#region 池状态查询

## 清理已释放的对象引用
## 从所有数组中移除已被释放的对象
func _cleanup_freed_objects() -> void:
	# 清理可用对象列表
	for i in range(_available.size() - 1, -1, -1):
		if not is_instance_valid(_available[i]):
			_available.remove_at(i)
			current_size -= 1
	
	# 清理活跃对象列表
	for i in range(_active.size() - 1, -1, -1):
		if not is_instance_valid(_active[i]):
			_active.remove_at(i)
			current_size -= 1

## 获取可用对象数量
## 
## [br][br][b]返回:[/b] [int] 当前可用的对象数量
func get_available_count() -> int:
	_cleanup_freed_objects()
	return _available.size()

## 获取活跃对象数量
## 
## [br][br][b]返回:[/b] [int] 当前活跃的对象数量
func get_active_count() -> int:
	_cleanup_freed_objects()
	return _active.size()

## 获取总对象数量
## 
## [br][br][b]返回:[/b] [int] 池中对象的总数量
func get_total_count() -> int:
	_cleanup_freed_objects()
	return _available.size() + _active.size()

#endregion
