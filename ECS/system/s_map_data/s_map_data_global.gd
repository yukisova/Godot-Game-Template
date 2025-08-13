## @editing: Sora [br]
## @describe: 地图数据管理系统 - 统一管理游戏地图和楼层切换
## 
## 该系统负责游戏中所有地图和楼层的加载、管理和切换逻辑，
## 取代了传统的scene_change模式，提供了更灵活的地图管理方案。
## 
## 核心功能：
## - 地图加载：动态加载和实例化地图场景
## - 楼层管理：处理不同楼层间的切换和激活
## - 实体放置：动态在地图中添加实体
## - 缓存管理：地图级别的数据缓存系统
## - 存档集成：与存档系统集成保存地图状态
## 
## 地图层次结构：
## - StaticMap：静态地图容器，包含多个楼层
## - Level：具体的游戏楼层，可独立激活/禁用
## - PlayerSpawn：玩家出生点，定义初始位置
## 
## 性能优化：
## - 楼层按需激活：只激活当前楼层，其他楼层禁用
## - 延迟加载：使用call_deferred优化加载性能
## - 内存管理：自动清理不需要的地图数据
## 
## 应用场景：
## - 开放世界：大型游戏世界的分区管理
## - 建筑内部：房屋、地下城的楼层切换
## - 场景传送：不同场景间的无缝切换
extends ISystem

## 实体动态添加信号
## 在游戏运行时向当前楼层动态添加新实体
## @param new_factor: 要添加的实体
## @param start_position: 实体的初始位置
signal factor_added(new_factor: IEntity, start_position: Vector2)

## 地图注册信号
## 游戏开始前注册要加载的地图场景
## @param map: 要注册的地图场景
signal map_info_registered(map: PackedScene)

## 楼层切换信号
## 当实体需要切换到不同楼层时发出
## @param operate_entity: 执行切换的实体
## @param new_level: 目标楼层
signal level_changed(operate_entity: IEntity, new_level: Level)

## 当前激活的楼层
## 指向当前玩家所在的活跃楼层
var current_level: Level

## 当前加载的地图
## 指向当前加载的静态地图实例
var current_map: StaticMap

## 系统初始化
## 连接地图管理相关的信号处理
func _enter_tree() -> void:
	factor_added.connect(_on_factor_added)
	map_info_registered.connect(_on_map_info_registered)
	level_changed.connect(_on_level_changed)

## 系统设置
## 地图系统的基础设置（当前无特殊设置需求）
func _setup():
	pass

## 系统重置
## 清理当前地图数据，准备加载新地图
func _resetup():
	current_level = null
	if current_map:
		current_map.queue_free()

## 地图场景加载处理
## 实例化地图场景并设置初始楼层和玩家位置
## @param map_scene: 要加载的地图场景
func _on_map_info_registered(map_scene: PackedScene):
	# 等待一帧确保系统准备就绪
	await get_tree().process_frame
	
	# 实例化地图场景
	var map = map_scene.instantiate() as StaticMap
	current_map = map
	
	# 隐藏所有HUD，只显示过渡界面
	SUiSpawner._hide_hud(["transition"])
	
	# 将地图添加到游戏视图
	Main.game_view.add_child(map)
	
	# 等待地图完成加载
	await SSignalBus.map_info_loaded
	
	# 处理玩家出生点
	var spawn = map.player_spawn
	if spawn != null:
		# 禁用所有楼层
		for level: Node in map.levels.get_children():
			level.process_mode = Node.PROCESS_MODE_DISABLED
			level.hide()
		
		# 激活玩家出生所在的楼层
		current_level = spawn.current_level
		current_level.process_mode = Node.PROCESS_MODE_INHERIT
		current_level.show()
		
		# 通知主控制器玩家位置
		SMainController.player_located.emit.call_deferred(spawn.current_level, spawn.global_position)
		
		# 清理出生点
		spawn.queue_free()
	else:
		push_warning("地图数据: 未检测到玩家出生点，请检查地图配置")

## 动态实体添加处理
## 在当前楼层中动态添加新实体
## @param new_factor: 要添加的新实体
## @param start_position: 实体的起始位置
func _on_factor_added(new_factor: IEntity, start_position: Vector2):
	# 延迟添加实体到当前楼层
	current_level.add_child.call_deferred(new_factor)
	
	# 设置实体位置
	new_factor.main_control.global_position = start_position
	
	# 初始化实体
	new_factor._initialize()

## 楼层切换处理
## 处理实体在不同楼层间的切换
## @param operate_entity: 执行切换的实体
## @param new_level: 目标楼层
func _on_level_changed(operate_entity: IEntity, new_level: Level):
	# 如果是玩家切换楼层，需要特殊处理
	if operate_entity.main_control.is_in_group("player"):
		# 禁用当前楼层
		current_level.hide()
		current_level.process_mode = Node.PROCESS_MODE_DISABLED
		
		# 更新相机限制范围
		var camera = operate_entity.list_base_components.get(IComponent.ComponentName.c_camera) as C_Camera
		if camera:
			camera.set_camera_limit(new_level.get_camera_limit())
		
		# 激活新楼层
		new_level.show()
		new_level.process_mode = Node.PROCESS_MODE_INHERIT
		current_level = new_level
	
	# 将实体重新分配到新楼层
	operate_entity.reparent(new_level)

## 获取地图缓存数据
## @param key: 缓存键名
## @param default: 默认值
## @return: 缓存值或默认值
func get_map_cache(key: String, default):
	if current_map:
		return current_map.cache_in_map.get_or_add(key, default)
	else:
		return default

## 设置地图缓存数据
## @param key: 缓存键名
## @param value: 要设置的值
## @param set_type: 设置类型（0=赋值，1=加法，2=减法）
func set_map_cache(key: String, value, set_type: int = 0):
	if current_map:
		match set_type:
			0: # 直接赋值
				current_map.cache_in_map[key] = value
			1: # 加法操作
				current_map.cache_in_map[key] += value
			2: # 减法操作
				current_map.cache_in_map[key] -= value

#region 存档系统集成
## 数据保存
## 收集当前地图的所有数据用于存档
## @param data: 存档数据文件
func _data_saving(data: SavedDataFile):
	if current_map:
		# 保存地图缓存数据
		data.map_cache = current_map.cache_in_map
		# 让地图自身保存详细数据
		current_map._save(data)

## 数据加载
## 从存档中恢复地图数据
## @param data: 存档数据文件
func _data_loading(_data: SavedDataFile):
	# TODO: 实现地图数据的加载逻辑
	pass
#endregion
