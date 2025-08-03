## @editing: Sora [br]
## @describe: FIXME 对象池系统，目标如下 [br]
##			  1. 目前的静态地图系统是基于层的，因此对象池也需要考虑到这一点 [br]
##			  2. 对象池在可以监测的同时可以在运行时动态对生成的预制体对象进行扩充
extends ISystem

var _pools: Dictionary[StringName, ObjectPool] = {}  # 存储所有对象池，Key为池ID，Value为对象池实例

# 初始化对象池
func register_pool(pool_key: String, prefab: PackedScene, initial_size: int) -> void:
	var pool = ObjectPool.new(prefab, initial_size)
	_pools[pool_key] = pool

# 从池中获取对象
func spawn(pool_key: StringName, position: Vector2) -> Node:
	if _pools.has(pool_key):
		return _pools[pool_key].spawn(position)
	push_error("对象池%s还没有注册！" % pool_key)
	return null

# 回收对象
func despawn(pool_key: StringName, obj: Node) -> void:
	if _pools.has(pool_key):
		_pools[pool_key].despawn(obj)
