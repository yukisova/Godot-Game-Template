## @editing: Sora [br]
## @describe: 静态地图类, s_map_data处理的主要对象

## 2025.8.4 更新: 
## 目前，StaticMap的作用更加偏向于可以无缝切换的地图，但是切换地图的逻辑必须要好好进行斟酌

@tool
class_name StaticMap
extends Node

signal filter_changed(point: float)

@export var player_spawn: PlayerSpawn ## 可选的玩家出生地
@export_range(0,1) var time: float ## 玩家所在的地区的时间信息, 用于与滤镜进行交互，实现昼夜循环效果

@export_subgroup("依赖")
@export var levels: Node2D ## 层级集
@export var autoload_cutscene: Node ## 自动加载的过场事件
@export var map_filter: CanvasModulate ## 地图滤镜
@export var filter_gradient: GradientTexture1D ## 滤镜的渐变效 果


## 用于统计用的层级数
var level_count: int = 0
var level_loaded_count :int = 0
var level_initialized_count : int = 0

## _ready: 当游戏数据完全加载完毕后（发出game_data_loaded_compelete信号），如果存在过场剧情逻辑, 则立刻执行
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	filter_changed.connect(time_change_filter) ## 当信号变动, 是游戏中的时间出现了变动 FIXME 但感觉这种写法有一定隐患，之后要想办法进行修改
	
	for level in levels.get_children():
		if level is Level:
			level.level_fully_loaded.connect(_on_level_fully_loaded)
			level.level_entity_fully_initialize.connect(_on_level_entity_fully_loaded)
			level_count += 1
	
	for cutscene in autoload_cutscene.get_children():
		SSignalBus.game_data_loaded_compelete.connect(cutscene._start)

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

## FIXME 名字过于奇怪，可以进行一波小优化
func time_change_filter(point: float):
	time = point
	map_filter.color = filter_gradient.gradient.sample(time)
