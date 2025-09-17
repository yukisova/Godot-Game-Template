## 相机视口容器 - 管理SubViewport的动态大小调整
## 根据主视口的大小变化动态调整SubViewport的尺寸，支持分屏和全屏模式
## [br][b]编辑者:[/b] Sora
class_name CameraViewport
extends SubViewportContainer

@export var camera: Camera2D
@export var viewport: SubViewport

var camera_limit: Vector4
var camera_target: Node2D
var camera_strategy: CameraFollowStrategy

## 当前分割类型
var split_type: SViewportManager.LayoutType
## 在分割中的位置索引 (0-3)
var split_index: int = 0

# 用于调试的变量
var _debug_show_conversion: bool = false

func _ready():
	# 监听主视口大小变化
	get_viewport().size_changed.connect(_on_main_viewport_size_changed)
	# 初始化SubViewport大小
	_update_viewport_size()
	# 设置子视口的输入模式
	if viewport:
		viewport.handle_input_locally = false # 输入由主视口处理

func _process(_delta: float) -> void:
	if camera_strategy:
		camera_strategy._strategy(self, _delta)

## 设置视口分割配置
## [param type]: 分割类型
## [param index]: 在分割布局中的位置索引
func set_split_config(type: SViewportManager.LayoutType, index: int = 0):
	split_type = type
	split_index = index
	_update_viewport_size()

## 根据分割类型和主视口大小更新SubViewport尺寸
func _update_viewport_size():
	if not viewport:
		return
		
	var main_viewport_size = get_viewport().get_visible_rect().size
	var new_size: Vector2
	
	match split_type:
		SViewportManager.LayoutType.SINGLE:
			new_size = main_viewport_size
		SViewportManager.LayoutType.DOUBLE_H:
			new_size = Vector2(main_viewport_size.x / 2, main_viewport_size.y)
		SViewportManager.LayoutType.DOUBLE_V:
			new_size = Vector2(main_viewport_size.x, main_viewport_size.y / 2)
		SViewportManager.LayoutType.QUAD:
			new_size = Vector2(main_viewport_size.x / 2, main_viewport_size.y / 2)
	
	# 确保大小至少为1x1像素，避免0大小导致的问题
	new_size.x = max(1, new_size.x)
	new_size.y = max(1, new_size.y)
	
	viewport.size = new_size
	
	# 调试信息
	print("SubViewport size updated: ", new_size, " (Split: ", split_type, ", Index: ", split_index, ")")

## 主视口大小改变时的回调
func _on_main_viewport_size_changed():
	_update_viewport_size()

## 获取推荐的容器大小（用于布局管理）
func get_recommended_container_size() -> Vector2:
	if viewport:
		return viewport.size
	else:
		return Vector2.ZERO

## 获取鼠标以当前视口为基准的世界坐标
## 
## 基于ray_interact_confirm.gd中的计算逻辑进行优化：
## 通过将视口中的鼠标坐标转换为世界坐标系中的位置
## 计算公式：world_mouse_pos = (viewport_mouse_pos - viewport_size/2.0) + camera_center
## 
## 此方法用于：
## - 获取鼠标在游戏世界中的实际位置
## - 计算从玩家到鼠标的方向向量
## - 射线交互系统的位置计算
## 
## [br][br][b]返回:[/b] 世界中的鼠标坐标
func get_world_mouse_position() -> Vector2:
	# 获取视口中的鼠标位置（已经处理了zoom缩放和分屏）
	var viewport_mouse_pos = get_viewport_mouse_position()
	
	# 获取视口尺寸
	var viewport_size = Vector2(viewport.size) if viewport else Vector2.ZERO
	
	# 获取相机中心位置（世界坐标）
	var camera_center = camera.get_screen_center_position() if camera else Vector2.ZERO
	
	# 根据ray_interact_confirm.gd的计算逻辑：
	# 将鼠标位置从视口坐标系转换为世界坐标系
	# mouse_pos - viewport_size/2.0 = 鼠标相对于视口中心的偏移量
	# + camera_center = 转换为世界坐标系中的绝对位置
	var world_mouse_pos = (viewport_mouse_pos - viewport_size / 2.0) + camera_center
	
	return world_mouse_pos

## 获取子视口中的正确鼠标位置
## 在分屏模式下使用此方法代替get_global_mouse_position()
## 已修复：现在正确处理相机zoom缩放导致的鼠标位置映射偏差问题
## [br][br][b]返回:[/b] 子视口中的鼠标坐标
func get_viewport_mouse_position() -> Vector2:
	if not viewport:
		return Vector2.ZERO

	# 1. 获取主视口中的鼠标位置
	var main_mouse_position = get_viewport().get_mouse_position()
	
	# 2. 获取视口容器在主视口中的位置和尺寸
	var container_rect = get_global_rect()
	
	# 3. 计算视口在主视口中的位置系数 (0-1范围)
	var relative_x = inverse_lerp(container_rect.position.x, container_rect.position.x + container_rect.size.x, main_mouse_position.x)
	var relative_y = inverse_lerp(container_rect.position.y, container_rect.position.y + container_rect.size.y, main_mouse_position.y)
	
	# 4. 将相对位置转换为子视口的像素坐标
	var viewport_pos = Vector2(
		relative_x * viewport.size.x,
		relative_y * viewport.size.y
	)
	
	# 5. 应用相机zoom缩放修正 - 修复zoom != Vector2(1,1)时的映射偏差
	if camera and is_instance_valid(camera):
		var camera_zoom = camera.zoom
		if camera_zoom != Vector2.ZERO:
			# 当zoom < 1时，相机显示更大范围，鼠标位置需要相应扩大
			# 当zoom > 1时，相机显示更小范围，鼠标位置需要相应缩小
			# 使用zoom的倒数来修正坐标偏移
			var zoom_correction = Vector2(1.0 / camera_zoom.x, 1.0 / camera_zoom.y)
			
			# 计算视口中心点
			var viewport_center = viewport.size * 0.5
			
			# 相对于中心点的偏移量
			var offset_from_center = viewport_pos - viewport_center
			
			# 应用zoom修正
			offset_from_center *= zoom_correction
			
			# 得到修正后的位置
			viewport_pos = viewport_center + offset_from_center
	
	# 调试输出
	if _debug_show_conversion and Engine.get_frames_drawn() % 30 == 0:
		print("------------------")
		print("容器位置: ", container_rect)
		print("主视口鼠标位置: ", main_mouse_position)
		print("相对位置系数: (", relative_x, ", ", relative_y, ")")
		if camera and is_instance_valid(camera):
			print("相机缩放: ", camera.zoom)
		print("子视口鼠标位置: ", viewport_pos)
		print("------------------")
	
	# 如果鼠标在容器范围外，将位置限制在视口内
	if not container_rect.has_point(main_mouse_position):
		viewport_pos.x = clamp(viewport_pos.x, 0, viewport.size.x)
		viewport_pos.y = clamp(viewport_pos.y, 0, viewport.size.y)
	
	return viewport_pos

## 将主视口坐标转换为子视口坐标
## 已修复：现在支持指定坐标转换，并正确处理相机zoom缩放
func main_to_subviewport_coords(main_pos: Vector2) -> Vector2:
	if not viewport:
		return Vector2.ZERO
	
	# 1. 获取视口容器在主视口中的位置和尺寸
	var container_rect = get_global_rect()
	
	# 2. 计算指定位置在视口中的相对位置系数 (0-1范围)
	var relative_x = inverse_lerp(container_rect.position.x, container_rect.position.x + container_rect.size.x, main_pos.x)
	var relative_y = inverse_lerp(container_rect.position.y, container_rect.position.y + container_rect.size.y, main_pos.y)
	
	# 3. 将相对位置转换为子视口的像素坐标
	var viewport_pos = Vector2(
		relative_x * viewport.size.x,
		relative_y * viewport.size.y
	)
	
	# 4. 应用相机zoom缩放修正
	if camera and is_instance_valid(camera):
		var camera_zoom = camera.zoom
		if camera_zoom != Vector2.ZERO:
			var zoom_correction = Vector2(1.0 / camera_zoom.x, 1.0 / camera_zoom.y)
			var viewport_center = viewport.size * 0.5
			var offset_from_center = viewport_pos - viewport_center
			offset_from_center *= zoom_correction
			viewport_pos = viewport_center + offset_from_center
	
	return viewport_pos

## 将子视口坐标转换为主视口坐标
## 已修复：现在正确处理相机zoom缩放的逆转换
func subviewport_to_main_coords(viewport_pos: Vector2) -> Vector2:
	if not viewport:
		return viewport_pos
	
	var corrected_viewport_pos = viewport_pos
	
	# 1. 应用相机zoom缩放的逆修正
	if camera and is_instance_valid(camera):
		var camera_zoom = camera.zoom
		if camera_zoom != Vector2.ZERO:
			# 这里需要应用zoom缩放（与main_to_subviewport_coords相反）
			var zoom_factor = camera_zoom
			var viewport_center = viewport.size * 0.5
			var offset_from_center = viewport_pos - viewport_center
			offset_from_center *= zoom_factor
			corrected_viewport_pos = viewport_center + offset_from_center
	
	var container_rect = get_global_rect()
	
	# 2. 将修正后的视口坐标转换为相对位置(0-1范围)
	var relative_x = corrected_viewport_pos.x / viewport.size.x
	var relative_y = corrected_viewport_pos.y / viewport.size.y
	
	# 3. 转换为主视口坐标
	return Vector2(
		lerp(container_rect.position.x, container_rect.position.x + container_rect.size.x, relative_x),
		lerp(container_rect.position.y, container_rect.position.y + container_rect.size.y, relative_y)
	)

## 获取此视口中某个世界坐标相对于相机的位置
## [br][br][b]返回:[/b] 相对于相机的坐标
func get_local_camera_position(world_pos: Vector2) -> Vector2:
	if camera and is_instance_valid(camera):
		return world_pos - camera.get_screen_center_position()
	return world_pos

## 开关调试输出
func toggle_debug_output(enabled: bool = true):
	_debug_show_conversion = enabled

## 测试不同zoom值下的鼠标位置映射准确性
## 这个方法可用于验证zoom缩放修复是否正确工作
func test_zoom_position_mapping():
	if not camera or not is_instance_valid(camera):
		print("CameraViewport: 无法进行测试，相机引用无效")
		return
	
	print("=== 相机zoom缩放鼠标位置映射测试 ===")
	
	# 保存当前zoom值
	var original_zoom = camera.zoom
	
	# 测试几个不同的zoom值
	var test_zoom_values = [
		Vector2(0.5, 0.5),   # 相机拉远，显示更大范围
		Vector2(1.0, 1.0),   # 标准缩放
		Vector2(2.0, 2.0),   # 相机拉近，显示更小范围
		Vector2(1.5, 1.5)    # 中等缩放
	]
	
	# 测试点（视口中心点）
	var test_points = [
		viewport.size * 0.5,    # 视口中心
		Vector2(0, 0),          # 视口左上角
		viewport.size,          # 视口右下角
		Vector2(viewport.size.x * 0.25, viewport.size.y * 0.75)  # 随机点
	]
	
	print("视口尺寸: ", viewport.size)
	
	for zoom_value in test_zoom_values:
		camera.zoom = zoom_value
		print("\n--- 测试zoom = ", zoom_value, " ---")
		
		for i in range(test_points.size()):
			var test_point = test_points[i]
			
			# 正向转换：子视口坐标 -> 主视口坐标
			var main_pos = subviewport_to_main_coords(test_point)
			# 反向转换：主视口坐标 -> 子视口坐标
			var converted_back = main_to_subviewport_coords(main_pos)
			
			# 计算转换误差
			var error = converted_back.distance_to(test_point)
			
			print("  测试点 ", i + 1, ": ", test_point)
			print("    -> 主视口: ", main_pos)
			print("    -> 转换回: ", converted_back)
			print("    误差: ", error, (", 精度: " + ("良好" if error < 1.0 else "待改进")))
	
	# 恢复原始zoom值
	camera.zoom = original_zoom
	print("\n测试完成，已恢复原始zoom值: ", original_zoom)
	print("=============================")

## 获取当前相机zoom缩放信息（调试用）
func get_camera_zoom_info() -> Dictionary:
	if not camera or not is_instance_valid(camera):
		return {"error": "无效的相机引用"}
	
	var viewport_size: Vector2 = Vector2.ZERO
	if viewport:
		viewport_size = viewport.size
	
	return {
		"zoom": camera.zoom,
		"zoom_description": _get_zoom_description(camera.zoom),
		"viewport_size": viewport_size
	}

## 获取zoom值的描述文本（调试用）
func _get_zoom_description(zoom: Vector2) -> String:
	if zoom.x < 1.0:
		return "拉远视角（显示更大范围）"
	elif zoom.x > 1.0:
		return "拉近视角（显示更小范围）"
	else:
		return "标准视角"

func _physics_process(_delta: float) -> void:
	if camera_target:
		camera.get_parent().global_position = camera_target.global_position
