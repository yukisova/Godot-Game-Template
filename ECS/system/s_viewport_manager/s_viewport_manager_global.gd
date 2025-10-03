extends ISystem

enum LayoutType {
	SINGLE,      # 单人模式 - 1个全屏视口
	DOUBLE_H,    # 双人模式 - 水平分割
	DOUBLE_V,    # 双人模式 - 垂直分割
	QUAD         # 四人模式 - 四分割
}
enum MouseMode {
	NORMAL,      # 正常模式 - 鼠标可以自由移动
	LOCKED,      # 锁定模式 - 鼠标锁定在第一个视口范围内
	CONFINED     # 限制模式 - 鼠标限制在第一个视口范围内但可以移动
}

@export var is_horizontal_split_viewport: bool
@export var camera_viewport_scene: PackedScene
@export var game_viewport_grid: GridContainer

var _mouse_locked: bool = false
var _last_mouse_position: Vector2 = Vector2.ZERO
var _first_viewport_rect: Rect2 = Rect2()

var current_camera: Camera2D
var camera_viewports: Array[CameraViewport] = []
var current_layout: LayoutType
var current_mouse_mode: MouseMode

func _setup():
	## 监听主视口大小变化
	get_viewport().size_changed.connect(_on_main_viewport_resized)
	## 监听输入事件
	get_viewport().gui_focus_changed.connect(_on_gui_focus_changed) ## 完成游戏数据加载之后，会正式开始
	SSignalBus.game_data_preloaded.connect(_setup_viewports_for_play_type)

func _resetup():
	clear_all_viewports()
	# 重新设置
	#_setup_viewports_for_play_type()

#region 原ViewportManager
## 设置布局类型并重新配置所有视口
## [param layout]: 新的布局类型
func set_layout(layout: LayoutType):
	current_layout = layout
	_configure_container_layout()
	_update_all_viewports()
	
## 添加视口到管理器
## [param camera_viewport]: 要添加的相机视口
func add_viewport(camera_viewport: CameraViewport):
		
	if not camera_viewport:
		push_error("ViewportManager: 传入的 camera_viewport 为空")
		return
		
	camera_viewports.append(camera_viewport)
	game_viewport_grid.add_child(camera_viewport)
	_update_viewport_config(camera_viewport, camera_viewports.size() - 1)

## 移除视口
## [param camera_viewport]: 要移除的相机视口  
func remove_viewport(camera_viewport: CameraViewport):
	var index = camera_viewports.find(camera_viewport)
	if index >= 0:
		camera_viewports.remove_at(index)
		# 添加防护检查，确保节点仍然是grid的子节点
		if is_instance_valid(camera_viewport) and camera_viewport.get_parent() == game_viewport_grid:
			game_viewport_grid.remove_child(camera_viewport)
		if is_instance_valid(camera_viewport):
			camera_viewport.queue_free()
		# 重新配置剩余视口
		_update_all_viewports()

## 清空所有视口
func clear_all_viewports():
	for viewport in camera_viewports:
		# 添加防护检查，确保节点仍然是grid的子节点
		if is_instance_valid(viewport) and viewport.get_parent() == game_viewport_grid:
			game_viewport_grid.remove_child(viewport)
		if is_instance_valid(viewport):
			viewport.queue_free()
	camera_viewports.clear()
	
## 配置GridContainer的列数和行数
func _configure_container_layout():
	if not game_viewport_grid:
		return
		
	match current_layout:
		LayoutType.SINGLE:
			game_viewport_grid.columns = 1
		LayoutType.DOUBLE_H:
			game_viewport_grid.columns = 2
		LayoutType.DOUBLE_V:
			game_viewport_grid.columns = 1
		LayoutType.QUAD:
			game_viewport_grid.columns = 2

## 更新所有视口的配置
func _update_all_viewports():
	for i in range(camera_viewports.size()):
		_update_viewport_config(camera_viewports[i], i)
	
	# 如果当前处于鼠标限制模式，重新计算限制区域
	if current_mouse_mode != MouseMode.NORMAL and not camera_viewports.is_empty():
		_update_mouse_confinement_area()

## 更新单个视口的配置
## [param camera_viewport]: 要更新的视口
## [param index]: 视口在列表中的索引
func _update_viewport_config(camera_viewport: CameraViewport, index: int):
	camera_viewport.set_split_config(current_layout, index)

## 获取当前布局信息
func get_layout_info() -> Dictionary:
	var main_size = get_viewport().get_visible_rect().size
	var viewport_count = camera_viewports.size()
	
	return {
		"layout_type": current_layout,
		"viewport_count": viewport_count,
		"main_viewport_size": main_size,
		"individual_viewport_size": _calculate_individual_size(main_size)
	}

## 计算单个视口的理论大小
func _calculate_individual_size(main_size: Vector2) -> Vector2:
	match current_layout:
		LayoutType.SINGLE:
			return main_size
		LayoutType.DOUBLE_H:
			return Vector2(main_size.x / 2, main_size.y)
		LayoutType.DOUBLE_V:
			return Vector2(main_size.x, main_size.y / 2)
		LayoutType.QUAD:
			return Vector2(main_size.x / 2, main_size.y / 2)
		_:
			return main_size

## 动态切换布局（运行时调用）
## [param new_layout]: 新的布局类型
## [param smooth_transition]: 是否使用平滑过渡效果
func switch_layout(new_layout: LayoutType, smooth_transition: bool = false):
	if smooth_transition:
		# 可以在这里添加过渡动画
		var tween = create_tween()
		tween.tween_method(_transition_layout, 0.0, 1.0, 0.3)
		await tween.finished
	
	set_layout(new_layout)

## 过渡动画的回调函数（可选实现）
func _transition_layout(_progress: float):
	# 在这里可以实现平滑的布局过渡效果
	pass

## 获取第一个视口（用于鼠标固定模式）
func get_first_viewport() -> CameraViewport:
	if camera_viewports.is_empty():
		return null
	return camera_viewports[0]

## 获取第一个视口的矩形范围
func get_first_viewport_rect() -> Rect2:
	var first_viewport = get_first_viewport()
	if not first_viewport:
		return Rect2()
	return first_viewport.get_global_rect()

#region 鼠标模式相关
## [param mode]: 新的鼠标模式
func set_mouse_mode(mode: MouseMode):
	if current_mouse_mode == mode:
		return
		
	var old_mode = current_mouse_mode
	current_mouse_mode = mode
	
	match mode:
		MouseMode.NORMAL:
			_release_mouse_lock()
		MouseMode.LOCKED:
			_lock_mouse_to_first_viewport()
		MouseMode.CONFINED:
			_confine_mouse_to_first_viewport()
	
	print("ViewportManager: 鼠标模式从 ", old_mode, " 切换到 ", mode)

## 获取当前鼠标模式
func get_mouse_mode() -> MouseMode:
	return current_mouse_mode

## 启用鼠标固定模式（便捷方法）
func enable_mouse_lock():
	set_mouse_mode(MouseMode.LOCKED)

## 启用鼠标限制模式（便捷方法）
func enable_mouse_confinement():
	set_mouse_mode(MouseMode.CONFINED)

## 禁用鼠标固定模式（便捷方法）
func disable_mouse_lock():
	set_mouse_mode(MouseMode.NORMAL)

## 切换鼠标固定模式（便捷方法）
func toggle_mouse_lock():
	if current_mouse_mode == MouseMode.NORMAL:
		set_mouse_mode(MouseMode.LOCKED)
	else:
		set_mouse_mode(MouseMode.NORMAL)

#region 要改造的方法（希望可以让鼠标的锁定区域不局限于当前的方法）
## 获取当前鼠标在第一个视口中的位置
func get_mouse_position_in_first_viewport() -> Vector2:
	var first_viewport = get_first_viewport()
	if not first_viewport:
		return Vector2.ZERO
	
	# 获取主视口中的鼠标位置
	var main_mouse_pos = get_viewport().get_mouse_position()
	
	# 转换为第一个视口中的位置
	return first_viewport.main_to_subviewport_coords(main_mouse_pos)

## 检查鼠标是否在第一个视口范围内
func is_mouse_in_first_viewport() -> bool:
	var first_viewport = get_first_viewport()
	if not first_viewport:
		return false
	
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_rect = first_viewport.get_global_rect()
	return viewport_rect.has_point(mouse_pos)

## 锁定鼠标到第一个视口
func _lock_mouse_to_first_viewport():
	if camera_viewports.is_empty():
		push_warning("ViewportManager: 没有可用的视口来锁定鼠标")
		return
	
	var first_viewport = camera_viewports[0]
	_first_viewport_rect = first_viewport.get_global_rect()
	
	# 计算第一个视口的中心位置
	var center_pos = _first_viewport_rect.position + _first_viewport_rect.size / 2
	
	# 锁定鼠标到第一个视口中心
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_mouse_locked = true
	
	# 设置鼠标位置到视口中心
	_last_mouse_position = center_pos
	
	# 将鼠标移动到视口中心
	Input.warp_mouse(center_pos)
	print("ViewportManager: 鼠标已锁定到第一个视口中心: ", center_pos)

## 限制鼠标在第一个视口范围内
func _confine_mouse_to_first_viewport():
	if camera_viewports.is_empty():
		push_warning("ViewportManager: 没有可用的视口来限制鼠标")
		return
	
	var first_viewport = camera_viewports[0]
	_first_viewport_rect = first_viewport.get_global_rect()
	
	# 释放鼠标锁定，但保持限制状态
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_mouse_locked = false
	
	print("ViewportManager: 鼠标已限制在第一个视口范围内")

#endregion

## 释放鼠标锁定
func _release_mouse_lock():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_mouse_locked = false
	print("ViewportManager: 鼠标锁定已释放")

## 更新鼠标限制区域
func _update_mouse_confinement_area():
	if camera_viewports.is_empty():
		return
	
	var first_viewport = camera_viewports[0]
	_first_viewport_rect = first_viewport.get_global_rect()
	
	# 如果当前处于锁定模式，重新设置鼠标位置到视口中心
	if current_mouse_mode == MouseMode.LOCKED:
		var center_pos = _first_viewport_rect.position + _first_viewport_rect.size / 2
		Input.warp_mouse(center_pos)
		_last_mouse_position = center_pos

## 处理鼠标位置限制（在CONFINED模式下调用）
func _process_mouse_confinement():
	if current_mouse_mode != MouseMode.CONFINED or camera_viewports.is_empty():
		return
	
	var first_viewport = camera_viewports[0]
	var current_rect = first_viewport.get_global_rect()
	
	# 更新视口矩形（以防大小发生变化）
	_first_viewport_rect = current_rect
	
	# 获取当前鼠标位置
	var current_mouse_pos = get_viewport().get_mouse_position()
	
	# 检查鼠标是否在第一个视口范围内
	if not current_rect.has_point(current_mouse_pos):
		# 将鼠标位置限制在视口范围内
		var clamped_pos = Vector2(
			clamp(current_mouse_pos.x, current_rect.position.x, current_rect.position.x + current_rect.size.x),
			clamp(current_mouse_pos.y, current_rect.position.y, current_rect.position.y + current_rect.size.y)
		)
		
		# 只有当位置确实发生变化时才移动鼠标，避免无限循环
		if clamped_pos != current_mouse_pos:
			Input.warp_mouse(clamped_pos)
			_last_mouse_position = clamped_pos

## 处理输入事件
func _input(event: InputEvent):
	if current_mouse_mode == MouseMode.NORMAL:
		return
	
	# 处理鼠标移动事件
	if event is InputEventMouseMotion:
		if current_mouse_mode == MouseMode.LOCKED:
			# 在锁定模式下，记录相对移动
			_last_mouse_position += event.relative
			
			# 确保鼠标位置在第一个视口范围内
			if camera_viewports.size() > 0:
				var first_viewport = camera_viewports[0]
				var viewport_rect = first_viewport.get_global_rect()
				
				_last_mouse_position.x = clamp(_last_mouse_position.x, 
					viewport_rect.position.x, viewport_rect.position.x + viewport_rect.size.x)
				_last_mouse_position.y = clamp(_last_mouse_position.y, 
					viewport_rect.position.y, viewport_rect.position.y + viewport_rect.size.y)
	
	# 处理按键事件（用于切换鼠标模式）
	elif event is InputEventKey and event.is_pressed():
		match event.keycode:
			KEY_F1:
				# F1键切换鼠标模式
				var next_mode = (current_mouse_mode + 1) % MouseMode.size()
				set_mouse_mode(next_mode)
			KEY_ESCAPE:
				# ESC键释放鼠标锁定
				if current_mouse_mode == MouseMode.LOCKED:
					set_mouse_mode(MouseMode.NORMAL)
			KEY_F2:
				if Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				else:
					Input.mouse_mode = Input.MOUSE_MODE_CONFINED

## 每帧处理鼠标限制
func _process(_delta: float):
	_process_mouse_confinement()

#endregion

## 主视口大小改变时的回调
func _on_main_viewport_resized():
	# 所有CameraViewport会自动处理大小变化，这里可以做额外的布局调整
	print("Main viewport resized, current layout: ", current_layout)
	
	# 如果当前处于鼠标限制模式，重新计算限制区域
	if current_mouse_mode != MouseMode.NORMAL:
		_update_mouse_confinement_area()

## GUI焦点改变时的回调
func _on_gui_focus_changed(_control: Control):
	# 当GUI焦点改变时，可能需要调整鼠标模式
	# _control: 获得焦点的控件（可能为null）
	pass
#endregion

## 初始化viewport
func _setup_viewports_for_play_type():
	_refresh_players_viewport(true)
	for i in camera_viewports.size():
		camera_viewports[i].camera_strategy = CFSAttachPlayer.new()

## 刷新viewport(将camera_target重新进行绑定)
func _refresh_viewports():
	_refresh_players_viewport()

func _refresh_players_viewport(is_first: bool = false):
	var play_type = SMainController.play_type
	match play_type:
		0:
			set_layout(LayoutType.SINGLE)
		1:
			if is_horizontal_split_viewport:
				set_layout(LayoutType.DOUBLE_H)
			else:
				set_layout(LayoutType.DOUBLE_V)
		_:
			set_layout(LayoutType.QUAD)
	
	for i in play_type+1:
		var camera_viewport: CameraViewport
		if is_first:
			camera_viewport = camera_viewport_scene.instantiate()
			camera_viewports.append(camera_viewport)
			add_viewport(camera_viewport)
			if i == SoraConstant.InputTarget.PLAYER1:
				current_camera = camera_viewport.camera
		else:
			camera_viewport = camera_viewports[i]
		camera_viewport.camera_target = SMainController._get_player_info_by_index(i).main_control
		if camera_viewport.camera_target == null:
			print("出现问题，索引",i,"对应的player不存在")
		camera_viewport.viewport.world_2d = SMapData.current_level.get_parent().world_2d

## 动态切换视口布局（可在运行时调用）
## [param layout]: 新的布局类型
func switch_viewport_layout(layout: LayoutType):
	switch_layout(layout, true)  # 使用平滑过渡

## 获取指定的viewport_container
func get_viewport_container(node: Node2D) -> CameraViewport:
	for viewport in camera_viewports:
		if viewport.camera_target == node:
			return viewport
	return null

#region 相机的效果(镜头抖动)
var camera_tween: Tween
## 过场剧情所可能使用的临时镜头
## 如果存在了临时镜头，则当前主镜头会被替换为临时镜头。
var temp_camera_2d: Camera2D:
	set(v):
		temp_camera_2d = v

func get_main_camera(camera_target: Node2D) -> Camera2D:
	var camera_viewport = get_viewport_container(camera_target)
	var camera_2d: Camera2D
	if camera_viewport:
		camera_2d = camera_viewport.camera
	else:
		return null
	return camera_2d
## 相机抖动
func camera_shake(camera_target: Node2D, effect_strength: float = 1.0, effect_time: float = 0.5):
	var camera_2d: Camera2D = get_main_camera(camera_target)
	if not camera_2d:
		return
	if camera_tween: camera_tween.kill()
	
	camera_tween = camera_target.get_tree().create_tween()
	camera_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	for i in effect_strength:
		var offset_strength = Vector2(randf_range(-effect_strength, effect_strength), randf_range(-effect_strength, effect_strength))
		camera_tween.stop()
		camera_tween.tween_property(camera_2d, "offset", offset_strength, effect_time/(effect_strength+3))
		camera_tween.play()
		await camera_tween.finished
		camera_2d.offset = Vector2.ZERO

func camera_strategy_change(camera_target: Node2D, strategy: CameraFollowStrategy):
	var camera_viewport = get_viewport_container(camera_target)
	if camera_viewport:
		camera_viewport.camera_strategy = strategy

func camera_zoom_change_immediately(camera_target: Node2D, zoom: Vector2):
	var camera_viewport = get_viewport_container(camera_target)
	var camera_2d: Camera2D
	if camera_viewport:
		camera_2d = camera_viewport.camera
	else:
		return
	camera_2d.zoom = zoom

func camera_zoom_change_gradually(camera_target: Node2D, zoom: Vector2, duration: float):
	var camera_2d: Camera2D = get_main_camera(camera_target)
	if not camera_2d:
		return

	if camera_tween: camera_tween.kill()
	
	camera_tween = camera_target.get_tree().create_tween()
	camera_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	camera_tween.tween_property(camera_2d, "zoom", zoom, duration)

func set_camera_limit(limit_dict: Dictionary):
	for viewport in camera_viewports:
		viewport.camera.limit_top = limit_dict.get("camera_top", -10000000)
		viewport.camera.limit_bottom = limit_dict.get("camera_bottom", 10000000)
		viewport.camera.limit_left = limit_dict.get("camera_left", -10000000)
		viewport.camera.limit_right = limit_dict.get("camera_right", 10000000)
#endregion
