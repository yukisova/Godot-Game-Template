class_name Level
extends Node2D

signal level_fully_loaded
signal level_entity_fully_initialize
signal level_component_initialized

@export var is_need_fog: bool
@export_range(0, 1) var time: float:
	set(value):
		if time != value:  # 避免重复设置
			time = value

@export_group("依赖")
@export var camera_limit: Control						# 相机限制
@export var rooms: LCRooms:								# 房间
	set(v):
		rooms = v
		rooms.belongs_level = self

@export var entity_state_manager: LCEntityStates:		# 层级对象池(同时也是实体状态管理器)
	set(v):
		entity_state_manager = v
		entity_state_manager.belongs_level = self

@export var entity_data_injecter: LCEntityDataInjecter:	# 实体数据注入器
	set(v):
		entity_data_injecter = v
		entity_data_injecter.belongs_level = self

@export var level_fog: Fog								# 迷雾
@export var paint_floors: PaintFloor					# 血迹地板
@export var map_filter: CanvasModulate					# 地图滤镜
@export var directional_light: DirectionalLight2D		# 方向光
@export var filter_gradient: GradientTexture1D			# 滤镜渐变

var static_map: StaticMap

var layers_count = 0
var layers_loaded_count = 0

var entity_count = 0
var entity_loaded_count = 0

func _enter_tree() -> void:
	for element in get_children():
		if element is TileMapLayer or element is PolygonTile:
			element.ready.connect(_on_layer_ready, CONNECT_DEFERRED)
			layers_count += 1
		elif element is FixedEntity:
			element.initialize_complete.connect(_on_entity_initialize)
			element.is_entity_origin_exist = true
			entity_count += 1
		elif element is ObjectEntity:
			if element is TransportPoint:
				if element.transport_point_key != "":
					static_map.exported_transport_points[element.transport_point_key] = element
			if not element.initialize_complete.is_connected(_on_entity_initialize):
				element.initialize_complete.connect(_on_entity_initialize)
			element.is_entity_origin_exist = true
			entity_count += 1
		elif element is PlayerSpawn:
			if element.transport_point_key != "":
				static_map.exported_transport_points[element.transport_point_key] = element
	_check_all_layers_loaded()
	await level_fully_loaded
	_check_all_entity_initialize()

func _on_layer_ready():
	layers_loaded_count += 1
	_check_all_layers_loaded()

func _on_entity_initialize():
	entity_loaded_count += 1
	_check_all_entity_initialize()

func _check_all_layers_loaded():
	if layers_loaded_count == layers_count:
		level_fully_loaded.emit()

func _check_all_entity_initialize():
	if entity_loaded_count == entity_count:
		level_entity_fully_initialize.emit()

func _late_initialize():
	if !is_need_fog:
		level_fog.hide()
	level_fog._initialize()
	paint_floors._initialize()
	rooms._initialize()
	entity_state_manager._initialize()
	_initialize_paint_batch()  # 初始化批处理机制
	var timeloop = SBlackboard.get_sub_system(ISubSystem.SubSystemType.TIME_LOOP) as SSTimeLoop
	timeloop.time_updated.connect(time_change_filter)
	time_change_filter(timeloop.real_time)
	level_component_initialized.emit()

func get_camera_limit() -> Dictionary:
	var limit_dict = {}
	var rect = camera_limit.get_global_rect()
	limit_dict["camera_top"] = rect.position.y
	limit_dict["camera_left"] = rect.position.x
	limit_dict["camera_right"] = rect.end.x
	limit_dict["camera_bottom"] = rect.end.y
	return limit_dict

#region :存档系统:
func _save_as(_data: SavedDataFile) -> Dictionary:
	var levels_result = {}
	for element in get_children():
		if element.has_method("_save_as"):
			levels_result.merge(element._save_as(_data))
	return { name:levels_result }

#endregion

func time_change_filter(point: float):
	_update_filter(point)

func _update_filter(time_value: float):
	if directional_light and filter_gradient:
		directional_light.color = filter_gradient.gradient.sample(time_value)


#region decal - 优化版本
# 批处理相关变量
var _paint_batch: Array[Dictionary] = []
var _paint_timer: Timer
var _max_batch_size: int = 10
var _batch_delay: float = 0.1  # 100ms延迟进行批处理

func _initialize_paint_batch():
	# 初始化批处理计时器
	if not _paint_timer:
		_paint_timer = Timer.new()
		_paint_timer.timeout.connect(_process_paint_batch)
		_paint_timer.one_shot = true
		add_child(_paint_timer)

## 优化的地面绘制 - 使用批处理
func try_paint_floor(target_position: Vector2, target_image: Image):
	# 添加到批处理队列
	_paint_batch.append({
		"position": target_position,
		"image": target_image,
		"image_position": SoraEvent._get_image_position(paint_floors, target_position, target_image.get_size())
	})
	
	# 如果达到批处理大小上限，立即处理
	if _paint_batch.size() >= _max_batch_size:
		_process_paint_batch()
		_paint_timer.stop()
	# 否则启动/重置计时器
	elif not _paint_timer.is_stopped():
		_paint_timer.start(_batch_delay)
	else:
		_paint_timer.start(_batch_delay)

## 批处理绘制所有待处理的decal
func _process_paint_batch():
	if _paint_batch.is_empty():
		return
	
	var _batch_count = _paint_batch.size()	
	# 一次性获取原始图像
	var origin_image = paint_floors.texture.get_image()
	
	# 批量处理所有decal
	for paint_data in _paint_batch:
		origin_image.blend_rect(
			paint_data.image, 
			Rect2i(Vector2.ZERO, paint_data.image.get_size()), 
			Vector2i(paint_data.image_position)
		)
	
	# 一次性更新texture
	(paint_floors.texture as ImageTexture).set_image(origin_image)
	
	# 清空批处理队列
	_paint_batch.clear()
	
	# 输出性能信息（可选）
	#print("批处理完成，处理了 ", _batch_count, " 个decal")

## 立即处理所有待处理的decal（用于游戏结束等情况）
func flush_paint_batch():
	if not _paint_batch.is_empty():
		_process_paint_batch()
		_paint_timer.stop()
#endregion
