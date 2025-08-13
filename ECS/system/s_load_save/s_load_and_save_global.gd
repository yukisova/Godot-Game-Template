## @editing: Sora [br]
## @describe: 存档系统 - 管理游戏数据的保存和加载机制
## 
## 该系统负责游戏状态的持久化存储，包括实体状态、组件数据、系统配置等。
## 采用递归收集的方式获取所有可存档数据，并提供统一的存档格式。
## 
## 存档范围：
## - 全局黑板数据（SBlackboard）
## - 地图数据和实体状态（SMapData）
## - 游戏运行时缓存数据
## - 系统配置信息
## 
## 功能特性：
## - 异步存档机制
## - 递归数据收集
## - 版本兼容性支持
## - 数据完整性验证
## - 运行时数据缓存
## 
## TODO: 优化存档性能，考虑增量存档和压缩存储
extends ISystem

## 游戏保存开始信号
## 触发系统开始收集和保存所有可存档数据
@warning_ignore("unused_signal")
signal saving_started

## 游戏加载开始信号
## 触发系统开始加载存档数据，等待所有加载项完成
signal loading_started

## 游戏加载刷新信号
## 当存档数据加载完成后触发，传递加载的数据字典
signal loading_refreshed(data: Dictionary)

## 游戏运行时数据缓存
## 存储游戏运行时的临时数据，用于全局共享（类似黑板功能）
## TODO: 考虑是否需要此功能，或用更好的方案替代
var gaming_data_cache: Dictionary = {}

## 当前存档数据
## 保存最近加载的存档文件引用，用于数据追踪和调试
var current_saved: SavedDataFile = null

## 节点初始化
## 连接存档和读档信号到对应的处理方法
func _enter_tree() -> void:
	saving_started.connect(_data_saving)
	loading_started.connect(_data_loading)

## 系统重置
## 清空运行时缓存数据，准备新的游戏会话
func _resetup():
	gaming_data_cache.clear()
	current_saved = null

## 执行数据保存
## 递归收集所有系统的可存档数据并保存到文件
func _data_saving():
	print("存档系统: 开始保存游戏数据...")
	
	# 创建新的存档数据容器
	var data = SavedDataFile.new()
	
	# 收集各系统的存档数据
	SBlackboard._data_saving(data)
	await SMapData._data_saving(data)
	
	# 保存运行时缓存数据
	if not gaming_data_cache.is_empty():
		data.add_system_data("LoadAndSave", {"gaming_cache": gaming_data_cache})
	
	# 写入存档文件
	var save_path = "res://test_save.json"
	var error = ResourceSaver.save(data, save_path)
	
	if error == OK:
		print("存档系统: 数据保存成功 -> ", save_path)
	else:
		push_error("存档系统: 数据保存失败，错误代码: " + str(error))

## 执行数据加载
## 从存档文件加载数据并分发给各个系统
func _data_loading():
	print("存档系统: 开始加载游戏数据...")
	
	var save_path = "res://test_save.json"
	
	# 检查存档文件是否存在
	if not FileAccess.file_exists(save_path):
		push_warning("存档系统: 存档文件不存在 -> " + save_path)
		return
	
	# 加载存档数据
	var data: SavedDataFile = ResourceLoader.load(save_path)
	if data == null:
		push_error("存档系统: 存档文件加载失败 -> " + save_path)
		return
	
	current_saved = data
	
	# 分发数据给各系统
	SBlackboard._data_loading(data)
	SMapData._data_loading(data)
	
	# 恢复运行时缓存
	var load_save_data = data.get_system_data("LoadAndSave")
	if load_save_data.has("gaming_cache"):
		gaming_data_cache = load_save_data.gaming_cache
	
	# 触发加载完成事件
	loading_refreshed.emit(data.get_all_data())
	print("存档系统: 数据加载完成")

## 设置运行时缓存数据
## @param key: 缓存键名
## @param value: 缓存值
func set_cache_data(key: String, value: Variant):
	gaming_data_cache[key] = value

## 获取运行时缓存数据
## @param key: 缓存键名
## @param default: 默认值
## @return: 缓存值或默认值
func get_cache_data(key: String, default: Variant = null) -> Variant:
	return gaming_data_cache.get(key, default)

## 检查运行时缓存是否存在
## @param key: 缓存键名
## @return: 是否存在
func has_cache_data(key: String) -> bool:
	return gaming_data_cache.has(key)
	
