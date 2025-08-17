## 对象池系统 - 管理游戏中临时实体的生成、复用和销毁
##
## 该系统实现了高效的对象池管理机制，用于优化频繁创建和销毁的临时实体（如子弹、特效等）。
## 通过预创建对象池来避免运行时的内存分配和垃圾回收开销。
##
## 核心功能：
## - 对象池管理：动态创建和管理多个对象池
## - 实体复用：重复使用已创建的实体以提高性能
## - 内存优化：减少频繁的内存分配和回收
## - 层级绑定：对象池与特定关卡绑定，支持自动清理
##
## 性能优化：
## - 预分配机制：系统启动时预创建指定数量的实体
## - 智能扩展：池容量不足时自动扩展
## - 快速查找：基于字符串名称的高效池查找
## - 批量清理：关卡切换时自动清理所有对象池
##
## 应用场景：
## - 子弹系统：频繁生成和销毁的子弹实体
## - 特效系统：粒子特效、爆炸效果等临时视觉元素
## - 音效系统：临时音频播放器实例
## - 临时标记：短期存在的游戏对象
##
## 架构设计：
## - 基于 [LevelObjectPool] 的具体对象池实现
## - 与 [SMapData] 系统的关卡生命周期集成
## - 支持 [TempEntity] 类型的临时实体管理
##
## [br][b]编辑者:[/b] Sora
extends ISystem

#region 层级的对象池

## 层级对象池清理信号
## 
## 当特定关卡的对象池需要清理时发出的信号。
## [param level]: 要清理对象池的关卡，类型为 [Level]
signal level_pool_cleared(level: Level)

#endregion

#region 对象池存储

## 对象池字典
## 
## 存储所有活跃的对象池实例。
## 键为池标识符（[StringName]），值为对象池实例（[LevelObjectPool]）。
## 使用 [PackedScene] 识别当前的对象池类型。
var _pools: Dictionary[StringName, LevelObjectPool] = {}

#endregion

func _setup():
	level_pool_cleared.connect(_on_pool_cleared)

func _resetup():
	pass

## 生成临时实体
## 
## 从指定对象池生成临时实体，如果对象池不存在则自动创建。
## [param _pool_key]: 对象池标识符，类型为 [StringName]
## [param _prefab]: 要生成的实体预制体，类型为 [PackedScene]
## [param _context]: 传递给实体的初始化上下文数据
## [param _position]: 实体的生成位置
## [br][br][b]返回:[/b] [TempEntity] 生成的临时实体实例
func _spawn(_pool_key: StringName, _prefab: PackedScene, _context: Dictionary, _position: Vector2) -> TempEntity:
	var pool_key_name = StringName(_pool_key)
	if !_pools.has(pool_key_name) or !_pools[pool_key_name]:
		register_pool(pool_key_name , _prefab, 20)
	var temp_entity = _pools[pool_key_name].spawn(_position, _context)
	return temp_entity

## 注册对象池
## 
## 创建新的对象池并注册到系统中。
## [param _pool_key]: 对象池标识符，类型为 [StringName]
## [param _prefab]: 对象池中使用的预制体，类型为 [PackedScene]
## [param _initial_pool_size]: 初始池大小，即预创建的实体数量
func register_pool(_pool_key:StringName, _prefab:PackedScene, _initial_pool_size:int):
	if _pools.has(_pool_key) and _pools[_pool_key] != null:
		print("目前已经存在",_pool_key, "请检查代码")
		return
	var new_pool = LevelObjectPool.new(_prefab, _initial_pool_size)
	_pools[_pool_key] = new_pool
	SMapData.current_level.level_object_pool.add_child(new_pool)

## 对象池清理处理
## 
## 当关卡切换时清理所有对象池，释放相关资源。
## [param level]: 要清理对象池的关卡，类型为 [Level]
func _on_pool_cleared(level: Level):
	_pools.clear()
	for object_pool: LevelObjectPool in level.level_object_pool.get_children():
		object_pool.queue_free()
