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
	
	# 写入存档文件
	var save_path = "res://test_save.tres"
	var error = ResourceSaver.save(data, save_path)
	
	if error == OK:
		print("存档系统: 数据保存成功 -> ", save_path)
	else:
		push_error("存档系统: 数据保存失败，错误代码: " + str(error))

## 执行数据加载
## 从存档文件加载数据并分发给各个系统
func _data_loading():
	print("存档系统: 开始加载游戏数据...")
	
	var save_path = "res://test_save.tres"
	
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
	
	print("存档系统: 数据加载完成")
