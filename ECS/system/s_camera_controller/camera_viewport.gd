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

## 获取子视口中的正确鼠标位置
## 在分屏模式下使用此方法代替get_global_mouse_position()
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
	
	# 调试输出
	if _debug_show_conversion and Engine.get_frames_drawn() % 30 == 0:
		print("------------------")
		print("容器位置: ", container_rect)
		print("主视口鼠标位置: ", main_mouse_position)
		print("相对位置系数: (", relative_x, ", ", relative_y, ")")
		print("子视口鼠标位置: ", viewport_pos)
		print("------------------")
	
	# 如果鼠标在容器范围外，将位置限制在视口内
	if not container_rect.has_point(main_mouse_position):
		viewport_pos.x = clamp(viewport_pos.x, 0, viewport.size.x)
		viewport_pos.y = clamp(viewport_pos.y, 0, viewport.size.y)
	
	return viewport_pos

## 将主视口坐标转换为子视口坐标
func main_to_subviewport_coords(_main_pos: Vector2) -> Vector2:
	# 与get_viewport_mouse_position使用相同的转换逻辑
	return get_viewport_mouse_position()

## 将子视口坐标转换为主视口坐标
func subviewport_to_main_coords(viewport_pos: Vector2) -> Vector2:
	if not viewport:
		return viewport_pos
		
	var container_rect = get_global_rect()
	
	# 将视口坐标转换为相对位置(0-1范围)
	var relative_x = viewport_pos.x / viewport.size.x
	var relative_y = viewport_pos.y / viewport.size.y
	
	# 转换为主视口坐标
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

func _physics_process(_delta: float) -> void:
	if camera_target:
		camera.get_parent().global_position = camera_target.global_position
