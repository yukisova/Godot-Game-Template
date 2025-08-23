## 视口管理器 - 统一管理多个SubViewport的动态分割
## 支持多种分割模式，自动处理视口大小调整和布局管理
## [br][b]编辑者:[/b] Sora
class_name ViewportManager
extends Node

## 分割布局类型
enum LayoutType {
	SINGLE,      # 单人模式 - 1个全屏视口
	DOUBLE_H,    # 双人模式 - 水平分割
	DOUBLE_V,    # 双人模式 - 垂直分割
	QUAD         # 四人模式 - 四分割
}

## 当前布局类型
var current_layout: LayoutType = LayoutType.SINGLE
## 管理的视口列表
var managed_viewports: Array[CameraViewport] = []
## 视口容器（GridContainer）
var viewport_container: GridContainer

## 初始化视口管理器
## [param container]: 用于放置视口的GridContainer
func initialize(container: GridContainer):
	if not container:
		push_error("ViewportManager: 传入的 GridContainer 为空")
		return
		
	viewport_container = container
	# 监听主视口大小变化
	get_viewport().size_changed.connect(_on_main_viewport_resized)

## 设置布局类型并重新配置所有视口
## [param layout]: 新的布局类型
func set_layout(layout: LayoutType):
	current_layout = layout
	_configure_container_layout()
	_update_all_viewports()

## 添加视口到管理器
## [param camera_viewport]: 要添加的相机视口
func add_viewport(camera_viewport: CameraViewport):
	if not viewport_container:
		push_error("ViewportManager: viewport_container 未初始化，请先调用 initialize()")
		return
		
	if not camera_viewport:
		push_error("ViewportManager: 传入的 camera_viewport 为空")
		return
		
	managed_viewports.append(camera_viewport)
	viewport_container.add_child(camera_viewport)
	_update_viewport_config(camera_viewport, managed_viewports.size() - 1)

## 移除视口
## [param camera_viewport]: 要移除的相机视口  
func remove_viewport(camera_viewport: CameraViewport):
	var index = managed_viewports.find(camera_viewport)
	if index >= 0:
		managed_viewports.remove_at(index)
		viewport_container.remove_child(camera_viewport)
		camera_viewport.queue_free()
		# 重新配置剩余视口
		_update_all_viewports()

## 清空所有视口
func clear_all_viewports():
	for viewport in managed_viewports:
		viewport_container.remove_child(viewport)
		viewport.queue_free()
	managed_viewports.clear()

## 配置GridContainer的列数和行数
func _configure_container_layout():
	if not viewport_container:
		return
		
	match current_layout:
		LayoutType.SINGLE:
			viewport_container.columns = 1
		LayoutType.DOUBLE_H:
			viewport_container.columns = 2
		LayoutType.DOUBLE_V:
			viewport_container.columns = 1
		LayoutType.QUAD:
			viewport_container.columns = 2

## 更新所有视口的配置
func _update_all_viewports():
	for i in range(managed_viewports.size()):
		_update_viewport_config(managed_viewports[i], i)

## 更新单个视口的配置
## [param camera_viewport]: 要更新的视口
## [param index]: 视口在列表中的索引
func _update_viewport_config(camera_viewport: CameraViewport, index: int):
	var split_type: CameraViewport.ViewportSplitType
	
	match current_layout:
		LayoutType.SINGLE:
			split_type = CameraViewport.ViewportSplitType.FULL_SCREEN
		LayoutType.DOUBLE_H:
			split_type = CameraViewport.ViewportSplitType.HORIZONTAL_2
		LayoutType.DOUBLE_V:
			split_type = CameraViewport.ViewportSplitType.VERTICAL_2
		LayoutType.QUAD:
			split_type = CameraViewport.ViewportSplitType.QUAD_4
	
	camera_viewport.set_split_config(split_type, index)

## 主视口大小改变时的回调
func _on_main_viewport_resized():
	# 所有CameraViewport会自动处理大小变化，这里可以做额外的布局调整
	print("Main viewport resized, current layout: ", current_layout)

## 获取当前布局信息
func get_layout_info() -> Dictionary:
	var main_size = get_viewport().get_visible_rect().size
	var viewport_count = managed_viewports.size()
	
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
