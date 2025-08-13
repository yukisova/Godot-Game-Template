## @editing: Sora [br]
## @describe: 对象池管理系统 - 统一管理游戏中的可重用对象
##
## 该系统提供高效的对象生命周期管理，主要用于：
## - 子弹、特效等频繁创建/销毁的对象
## - 敌人、道具等动态生成的游戏实体
## - UI元素的动态创建和回收
##
## 设计目标：
## 1. 支持基于层级的静态地图系统
## 2. 运行时动态扩充对象池容量
## 3. 自动监控和优化内存使用
## 4. 提供统一的对象生命周期接口
##
## 优势：
## - 减少GC压力，提高性能
## - 避免频繁的内存分配和释放
## - 统一的对象管理接口
## - 支持预加载和懒加载
extends ISystem

#region 对象池存储

## 对象池字典
## Key: 池标识符, Value: 对象池实例
var _pools: Dictionary[StringName, ObjectPool] = {}

#endregion

#region 对象池管理

## 注册新的对象池
## @param pool_key: 对象池的唯一标识符
## @param prefab: 对象的预制体场景
## @param initial_size: 初始对象数量
func register_pool(pool_key: String, prefab: PackedScene, initial_size: int) -> void:
	if _pools.has(pool_key):
		push_warning("对象池系统: 池 '%s' 已存在，将被覆盖" % pool_key)
	
	var pool = ObjectPool.new(prefab, initial_size)
	_pools[pool_key] = pool
	print("对象池系统: 注册对象池 '%s'，初始大小: %d" % [pool_key, initial_size])

## 从对象池获取对象
## @param pool_key: 对象池标识符
## @param position: 对象的初始位置
## @return: 获取的对象实例，失败时返回null
func spawn(pool_key: StringName, position: Vector2) -> Node:
	if _pools.has(pool_key):
		var obj = _pools[pool_key].spawn(position)
		print("对象池系统: 从池 '%s' 生成对象于位置 %v" % [pool_key, position])
		return obj
	
	push_error("对象池系统: 对象池 '%s' 尚未注册！" % pool_key)
	return null

## 回收对象到对象池
## @param pool_key: 对象池标识符  
## @param obj: 要回收的对象
func despawn(pool_key: StringName, obj: Node) -> void:
	if _pools.has(pool_key):
		_pools[pool_key].despawn(obj)
		print("对象池系统: 对象已回收到池 '%s'" % pool_key)
	else:
		push_error("对象池系统: 无法回收对象，池 '%s' 不存在" % pool_key)

## 获取对象池统计信息
## @param pool_key: 对象池标识符
## @return: 包含池状态的字典
func get_pool_stats(pool_key: StringName) -> Dictionary:
	if _pools.has(pool_key):
		var pool = _pools[pool_key]
		return {
			"available_count": pool._available.size(),
			"active_count": pool._active.size(),
			"total_count": pool._available.size() + pool._active.size()
		}
	return {}

## 清理指定对象池
## @param pool_key: 要清理的对象池标识符
func clear_pool(pool_key: StringName) -> void:
	if _pools.has(pool_key):
		_pools.erase(pool_key)
		print("对象池系统: 已清理对象池 '%s'" % pool_key)

#endregion

#region 系统生命周期

## 系统设置
func _setup():
	print("对象池系统: 初始化完成")

## 系统重置
func _resetup():
	print("对象池系统: 开始重置，清理所有对象池")
	_pools.clear()

#endregion
