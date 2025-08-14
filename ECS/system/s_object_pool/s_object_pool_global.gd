extends ISystem

#region 层级的对象池
## 层级的
signal level_pool_cleared(level: Level)
#endregion

#region 对象池存储

## 对象池字典
## Key: 池标识符, Value: 对象池实例
## 使用packed_scene识别当前的子弹池
var _pools: Dictionary[StringName, LevelObjectPool] = {}

#endregion

func _setup():
	level_pool_cleared.connect(_on_pool_cleared)

func _resetup():
	pass

## 放置临时的子弹，_despawn的逻辑由level_object_pool确定
func _spawn(_pool_key: StringName, _prefab: PackedScene, _context: Dictionary, _position: Vector2) -> TempEntity:
	var pool_key_name = StringName(_pool_key)
	if !_pools.has(pool_key_name):
		register_pool(pool_key_name , _prefab, 20)
	var temp_entity = _pools[pool_key_name].spawn(_position, _context)
	return temp_entity

func register_pool(_pool_key:StringName, _prefab:PackedScene, _initial_pool_size:int):
	if _pools.has(_pool_key):
		print("目前已经存在",_pool_key, "请检查代码")
		return
	var new_pool = LevelObjectPool.new(_prefab, _initial_pool_size)
	_pools[_pool_key] = new_pool
	SMapData.current_level.level_object_pool.add_child(new_pool)

func _on_pool_cleared(level: Level):
	_pools.clear()
	for object_pool: LevelObjectPool in level.level_object_pool.get_children():
		object_pool.queue_free()
