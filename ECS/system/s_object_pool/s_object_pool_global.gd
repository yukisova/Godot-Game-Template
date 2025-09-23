extends ISystem

#region :层级的对象池:

signal level_pool_cleared(level: Level)

#endregion

#region :对象池存储:

var _pools: Dictionary[StringName, LevelObjectPool] = {}

#endregion

func _setup():
	level_pool_cleared.connect(_on_pool_cleared)

func _resetup():
	pass

## 生成临时实体—从指定对象池生成临时实体，如果对象池不存在则自动创建
func _spawn(_pool_key: StringName, _prefab: PackedScene, _context: Dictionary, _position: Vector2) -> TempEntity:
	var pool_key_name = StringName(_pool_key)
	if !_pools.has(pool_key_name) or !_pools[pool_key_name]:
		if _prefab:
			register_pool(pool_key_name , _prefab, 20)
		else:
			# push_warning("对象池: 对象池不存在，且未提供预制体，无法生成临时实体")
			return null
	var temp_entity = _pools[pool_key_name].spawn(_position, _context)
	return temp_entity

## 注册对象池—创建新的对象池并注册到系统中
func register_pool(_pool_key:StringName, _prefab:PackedScene, _initial_pool_size:int):
	if _pools.has(_pool_key) and _pools[_pool_key] != null:
		return
	var new_pool = LevelObjectPool.new(_prefab, _initial_pool_size)
	_pools[_pool_key] = new_pool
	SMapData.current_level.level_object_pool.add_child(new_pool)

## 对象池清理处理—当关卡切换时清理所有对象池，释放相关资源
func _on_pool_cleared(level: Level):
	_pools.clear()
	for object_pool: LevelObjectPool in level.level_object_pool.get_children():
		object_pool.queue_free()
