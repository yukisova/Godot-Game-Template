## 静态地图系统 - 游戏地图的核心管理组件
## 该类是游戏地图系统的核心，负责管理静态地图的所有方面
## 多层级地图结构的组织和加载、昼夜循环和视觉滤镜系统、玩家出生点和传送点管理
## 主要功能：协调多个Level的加载和初始化、管理地图的视觉效果、处理地图内的临时数据缓存
## 技术特性：异步的多层级加载机制、基于信号的加载状态协调、可编辑器预览的工具支持
## 应用场景：游戏关卡和场景的基础容器、世界地图的区域划分、副本和特殊场景的管理
## [br][b]编辑者:[/b] Sora
@tool
class_name StaticMap
extends Node

#region 地图信号
# 注意：已移除filter_changed信号，改为直接方法调用避免递归
#endregion

#region 玩家配置

## 玩家出生点
## 指定玩家在此地图中的初始位置和层级，类型为 [PlayerSpawn]
@export var player_spawns: Array[PlayerSpawn]

## 地图时间
## 控制昼夜循环的时间值（0.0-1.0），影响地图滤镜效果
@export_range(0, 1) var time: float:
	set(value):
		if time != value:  # 避免重复设置
			time = value
			# 直接更新滤镜，避免信号循环
			_update_filter(time)

#endregion

#region 地图组件依赖

@export_subgroup("依赖")

## 层级集合
## 包含所有Level层级的容器节点，类型为 [Node2D]
@export var levels: Node2D

## 自动加载过场事件
## 地图加载完成后自动播放的过场剧情，类型为 [Node]
@export var autoload_cutscene: Node

## 地图滤镜
## 用于实现昼夜循环视觉效果的画布调制器，类型为 [CanvasModulate]
# @export var map_filter: CanvasModulate

## 滤镜渐变纹理
## 定义昼夜循环的颜色变化曲线，类型为 [GradientTexture1D]
@export var filter_gradient: GradientTexture1D

## 是否启用过场剧情
## 控制地图加载后是否自动播放过场动画
@export var cutscene_enable: bool = true

## 导出的传送点列表
## 在level加载完毕后刷新，可以被其他地图的传送点直接引用
var exported_transport_points: Dictionary[StringName, TransportPoint] = {}

#endregion

#region 地图数据

## 地图内临时缓存
## 存储仅在当前地图有效的临时数据，如对话状态、临时标记、局部变量等
var cache_in_map: Dictionary

#endregion

#region 加载状态统计

## 总层级数量
var level_count: int = 0

## 已加载层级数量
var level_loaded_count: int = 0

## 已初始化层级数量
var level_initialized_count: int = 0

#endregion

## _ready: 当游戏数据完全加载完毕后（发出game_data_loaded_compelete信号），如果存在过场剧情逻辑, 则立刻执行
func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	
	# 移除了filter_changed信号连接，改为直接方法调用避免递归
	print("静态地图: 初始化完成，层级数量: ", level_count)

	for level in levels.get_children():
		if level is Level:
			# 创建一个子视口，用于隔离level的渲染
			var viewport = SubViewport.new()
			levels.add_child(viewport)
			level.reparent(viewport)

			level.level_fully_loaded.connect(_on_level_fully_loaded)
			level.level_entity_fully_initialize.connect(_on_level_entity_fully_loaded)
			level.static_map = self
			level_count += 1
	
	# 确保所有level的后期初始化始终被执行（修复迷雾系统bug）
	SMapData.map_register_finished.connect(_initialize_all_levels)
	
	if cutscene_enable:
		for cutscene in autoload_cutscene.get_children():
			SSignalBus.game_loop_start.connect(cutscene._start)
	else:
		SSignalBus.game_loop_start.connect(func():
			SUiSpawner._get_hud("transition").fade_in()
		)

## 所有楼层的信息全部完成加载后发出
func _on_level_fully_loaded():
	level_loaded_count += 1
	if level_loaded_count == level_count:
		SSignalBus.map_info_loaded.emit.call_deferred()

## 所有楼层的实体全部完成初始化后
func _on_level_entity_fully_loaded():
	level_initialized_count += 1
	if level_initialized_count == level_count:
		SSignalBus.game_data_loaded_compelete.emit.call_deferred()

## 由外部系统（如时间子系统）调用来更新地图时间
## [param point]: 时间点值
func time_change_filter(point: float):
	# 直接更新滤镜，不通过time属性setter避免循环
	_update_filter(point)

## 直接更新地图滤镜颜色，避免递归调用
## [param time_value]: 时间值
func _update_filter(time_value: float):
	# if map_filter and filter_gradient:
	# 	map_filter.color = filter_gradient.gradient.sample(time_value)
	pass

#region :存档系统:
func _save(data: SavedDataFile):
	var map_result = {}
	for level: Level in levels.get_children():
		map_result.merge(level._save_as(data))
	
	data.level_info = map_result
#endregion

## 工具方法
func get_level_by_name(_name: StringName) -> Level:
	for level in levels.get_children():
		if level is Level and level.name == _name:
			return level
	return null

func get_level_by_index(_index: int) -> Level:
	var i = 0
	for level in levels.get_children():
		if level is Level:
			if i == _index:
				return level
			i += 1
	return null

#region :楼层碰撞导航统一管理:

## 禁用所有楼层的碰撞导航
## 用于初始化或切换地图时确保所有楼层碰撞导航都被禁用
func disable_all_levels_collision_navigation():
	for level in levels.get_children():
		if level is Level:
			level.disable_all_collision_navigation()
	print("静态地图: 已禁用所有楼层的碰撞导航")

## 启用指定楼层的碰撞导航
## @param target_level: 要启用的楼层
func enable_level_collision_navigation_only(target_level: Level):
	# 先禁用所有楼层
	disable_all_levels_collision_navigation()
	# 然后只启用指定楼层
	if target_level and target_level.get_parent() == levels:
		target_level.enable_all_collision_navigation()
		print("静态地图: 仅楼层 ", target_level.level_id, " 的碰撞导航已启用")
	else:
		push_warning("静态地图: 无效的目标楼层，无法启用碰撞导航")

## 获取当前启用碰撞导航的楼层列表
## @return: 启用碰撞导航的楼层数组
func get_collision_navigation_enabled_levels() -> Array[Level]:
	var enabled_levels: Array[Level] = []
	for level in levels.get_children():
		if level is Level and level.is_collision_navigation_enabled():
			enabled_levels.append(level)
	return enabled_levels

## 检查是否只有一个楼层启用碰撞导航
## @return: true表示只有一个楼层启用，false表示有多个或没有楼层启用
func is_single_level_collision_navigation_enabled() -> bool:
	var enabled_count = get_collision_navigation_enabled_levels().size()
	return enabled_count == 1

## 初始化所有层级的后期组件—确保迷雾和房间系统正确初始化
func _initialize_all_levels():
	print("静态地图: 开始初始化所有层级的后期组件...")
	for level in levels.get_children():
		if level is Level:
			level._late_initialize()
			print("静态地图: 层级 %s 后期初始化完成" % level.name)

#endregion
