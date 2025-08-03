## @editing: Sora [br]
## @describe: 对象池基础类，目前的主要应用者为各种子弹
class_name ObjectPool
extends RefCounted

var _prefab: PackedScene ## 当前对象池基于的预制体
var _available: Array[Node] = [] ## 当前对象池中的空闲对象
var _active: Array[Node] = [] ## 当前对象池中正在使用的对象

## 定义的方法
func _init(prefab: PackedScene, initial_size: int):
	_prefab = prefab
	for i in range(initial_size):
		var obj = _prefab.instantiate()
		_disable_node(obj)
		_available.append(obj)

# 获取对象
func spawn(position: Vector2) -> Node:
	var obj: Node
	if _available.is_empty():
		obj = _prefab.instantiate()
	else:
		obj = _available.pop_back()
	
	_reset_node(obj, position)  # 重置位置/状态
	obj.process_mode = Node.PROCESS_MODE_INHERIT
	obj.show()
	_active.append(obj)
	return obj

# 回收对象
func despawn(obj: Node) -> void:
	if _active.has(obj):
		_active.erase(obj)
		_disable_node(obj)
		_available.append(obj)

# 禁用节点
func _disable_node(obj: Node) -> void:
	obj.process_mode = Node.PROCESS_MODE_DISABLED
	obj.hide()
	if obj.is_inside_tree():
		obj.get_parent().remove_child(obj)

# FIXME 重置对象的状态（需子类重写），这个方法的核心是子类重定义的方法
func _reset_node(obj: Node, position: Vector2) -> void:
	obj.position = position
	if obj.has_method("reset"):
		obj.reset()  # 要求可回收对象实现reset()方法
