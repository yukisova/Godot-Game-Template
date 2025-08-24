## 视口工具 - 提供视口相关的实用功能
## 主要用于处理分屏显示下的鼠标位置转换等问题
## [br][b]编辑者:[/b] Sora
class_name ViewportUtils
extends RefCounted

## 从主视口坐标转换为子视口坐标
## 当使用SubViewport和SubViewportContainer时，get_global_mouse_position()会返回相对于主视口的位置
## 此函数将主视口坐标转换为子视口内的正确坐标
## [param viewport_container]: 视口容器，类型为[SubViewportContainer]
## [param main_viewport_coords]: 主视口中的坐标位置，类型为[Vector2]
## [br][br][b]返回:[/b] 转换后的子视口坐标
static func main_to_subviewport_coords(viewport_container: SubViewportContainer, main_viewport_coords: Vector2) -> Vector2:
	# 1. 获取视口容器在主视口中的全局位置和尺寸
	var container_rect = viewport_container.get_global_rect()
	
	# 2. 计算鼠标在容器中的相对位置
	var local_coords = main_viewport_coords - container_rect.position
	
	# 3. 计算比例缩放因子（容器可能被缩放了）
	var viewport: SubViewport = viewport_container.get("viewport") as SubViewport
	if not viewport:
		return local_coords
	
	var scale_factor = Vector2(
		viewport.size.x / container_rect.size.x,
		viewport.size.y / container_rect.size.y
	)
	
	# 4. 应用缩放因子得到子视口中的正确坐标
	return local_coords * scale_factor

## 获取正确的子视口鼠标位置
## 这是一个便捷方法，用于获取当前鼠标在子视口中的正确位置
## 特别适合用于分屏显示时获取鼠标位置
## [param viewport_container]: 视口容器，类型为[SubViewportContainer]
## [br][br][b]返回:[/b] 在子视口中的鼠标坐标
static func get_subviewport_mouse_position(viewport_container: SubViewportContainer) -> Vector2:
	# 获取主视口中的鼠标位置
	var main_mouse_pos = viewport_container.get_viewport().get_mouse_position()
	# 转换为子视口坐标
	return main_to_subviewport_coords(viewport_container, main_mouse_pos)
