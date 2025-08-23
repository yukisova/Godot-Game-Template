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

## 视口分割类型
enum ViewportSplitType {
	FULL_SCREEN,    # 全屏 1x1
	HORIZONTAL_2,   # 水平分割 2x1  
	VERTICAL_2,     # 垂直分割 1x2
	QUAD_4          # 四分割 2x2
}

## 当前分割类型
var split_type: ViewportSplitType = ViewportSplitType.FULL_SCREEN
## 在分割中的位置索引 (0-3)
var split_index: int = 0

func _ready():
	# 监听主视口大小变化
	get_viewport().size_changed.connect(_on_main_viewport_size_changed)
	# 初始化SubViewport大小
	_update_viewport_size()

## 设置视口分割配置
## [param type]: 分割类型
## [param index]: 在分割布局中的位置索引
func set_split_config(type: ViewportSplitType, index: int = 0):
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
		ViewportSplitType.FULL_SCREEN:
			new_size = main_viewport_size
		ViewportSplitType.HORIZONTAL_2:
			new_size = Vector2(main_viewport_size.x / 2, main_viewport_size.y)
		ViewportSplitType.VERTICAL_2:
			new_size = Vector2(main_viewport_size.x, main_viewport_size.y / 2)
		ViewportSplitType.QUAD_4:
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


func _physics_process(_delta: float) -> void:
	if camera_target:
		camera.get_parent().global_position = camera_target.global_position
