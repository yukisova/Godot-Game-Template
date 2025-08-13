## @editing: Sora [br]
## @describe: 对象池基础类 - 实现高效的对象重用机制
##
## 该类为游戏中频繁创建和销毁的对象提供高效的内存管理：
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
## - 可被重用的对象应实现reset()方法来重置状态
## - 对象应能够正确处理启用/禁用状态切换
class_name ObjectPool
extends RefCounted

#region 对象池数据

## 对象预制体
## 用于创建新对象的模板场景
var _prefab: PackedScene

## 可用对象列表
## 存储当前未使用的对象实例
var _available: Array[Node] = []

## 活跃对象列表  
## 存储当前正在使用的对象实例
var _active: Array[Node] = []

#endregion

#region 初始化

## 对象池构造函数
## @param prefab: 对象的预制体场景
## @param initial_size: 初始预分配的对象数量
func _init(prefab: PackedScene, initial_size: int):
	_prefab = prefab
	
	# 预分配指定数量的对象
	for i in range(initial_size):
		var obj = _prefab.instantiate()
		_disable_node(obj)
		_available.append(obj)
	
	print("对象池: 初始化完成，预分配 %d 个对象" % initial_size)

#endregion

#region 对象生命周期管理

## 从对象池获取对象
## @param position: 对象的初始位置
## @return: 获取的对象实例
func spawn(position: Vector2) -> Node:
	var obj: Node
	
	# 如果没有可用对象，创建新的对象
	if _available.is_empty():
		obj = _prefab.instantiate()
		print("对象池: 池已空，动态创建新对象")
	else:
		obj = _available.pop_back()
	
	# 重置对象状态并激活
	_reset_node(obj, position)
	obj.process_mode = Node.PROCESS_MODE_INHERIT
	obj.show()
	_active.append(obj)
	
	return obj

## 回收对象到对象池
## @param obj: 要回收的对象
func despawn(obj: Node) -> void:
	if _active.has(obj):
		_active.erase(obj)
		_disable_node(obj)
		_available.append(obj)
	else:
		push_warning("对象池: 尝试回收不属于此池的对象")

#endregion

#region 对象状态管理

## 禁用对象
## 将对象设置为不可见和不处理状态
## @param obj: 要禁用的对象
func _disable_node(obj: Node) -> void:
	obj.process_mode = Node.PROCESS_MODE_DISABLED
	obj.hide()
	
	# 如果对象在场景树中，将其移除
	if obj.is_inside_tree():
		obj.get_parent().remove_child(obj)

## 重置对象状态
## 设置对象的位置并调用其重置方法（如果存在）
## @param obj: 要重置的对象
## @param position: 新的位置
func _reset_node(obj: Node, position: Vector2) -> void:
	obj.position = position
	
	# 如果对象实现了reset方法，调用它来重置状态
	if obj.has_method("reset"):
		obj.reset()

#endregion

#region 池状态查询

## 获取可用对象数量
## @return: 当前可用的对象数量
func get_available_count() -> int:
	return _available.size()

## 获取活跃对象数量
## @return: 当前活跃的对象数量  
func get_active_count() -> int:
	return _active.size()

## 获取总对象数量
## @return: 池中对象的总数量
func get_total_count() -> int:
	return _available.size() + _active.size()

#endregion
