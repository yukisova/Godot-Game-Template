## 游戏事件工具类 - 提供常用的静态方法和事件处理
##
## 该类封装了游戏中常用的事件处理方法，主要包括：
## - 对话系统的便捷调用
## - 通用事件触发器
## - 场景切换工具
## - 其他常用的静态工具方法
##
## 设计目标：
## - 简化复杂系统的调用流程
## - 提供统一的事件处理接口
## - 减少代码重复和耦合
##
## 工具方法：
## - 字典数据修复和转换
## - 节点路径解析和处理
## - 数据结构的深度处理
##
## 架构设计：
## - 继承自 [Node] 基类
## - 提供静态方法 [method fixed_dictionary]
## - 支持 [NodePath] 到 [Node] 的自动转换
## - 基于递归的深度数据处理
##
## [br][b]编辑者:[/b] Sora
class_name SoraEvent
extends Node

## 修复字典中的NodePath值
## 
## 递归地将字典中的 [NodePath] 值转换为实际的节点引用。
## 支持嵌套字典和数组的深度处理。
## [param node]: 作为路径解析基准的节点
## [param data]: 包含 [NodePath] 的字典数据
## [br][br][b]返回:[/b] [Dictionary] 修复后的字典，所有 [NodePath] 被转换为对应的 [Node] 引用
static func fixed_dictionary(node: Node, data: Dictionary) -> Dictionary:
	var result = {}
	# 遍历所有键值对，处理不同类型的值
	for key in data:
		if data[key] is NodePath:
			# 将NodePath转换为实际的节点引用
			result[key] = node.get_node(data[key])
		elif data[key] is Dictionary:
			# 递归处理嵌套字典
			result[key] = fixed_dictionary(node, data[key])
		elif data[key] is Array:
			result[key] = []
			for i in data[key].size():
				if data[key][i] is Dictionary:
					result[key].append(fixed_dictionary(node, data[key][i]))
				elif data[key][i] is NodePath:
					result[key].append(node.get_node(data[key][i]))
				elif data[key][i] is Array:
					printerr("不会fix嵌套Array的内容")
					result[key].append(data[key][i])
				else:
					result[key].append(data[key][i])
		elif data[key] is ContainerBlackboardData:
			result[key] = fixed_dictionary(node, (data[key] as ContainerBlackboardData)._data as Dictionary)
		else:
			result[key] = data[key]
			
	return result


#region 相机特效相关
## 根据ViewportManager中的信息，获取
static func fixed_camera_position(camera_target: Node2D) -> Dictionary:
	var camera_viewport = SViewportManager.get_viewport_container(camera_target)
	var result = {}
	if camera_viewport:
		result["viewport_mouse_pos"] = camera_viewport.get_viewport_mouse_position()
		result["world_mouse_pos"] = camera_viewport.get_world_mouse_position()
		result["player_pos"] = camera_target.global_position
		result["camera_center"] = camera_viewport.camera.get_screen_center_position()
		result["viewport_size"] = camera_viewport.viewport.size
	return result
#endregion

#region 渲染相关

## 旋转图像
static func _set_image_rotation(image: Image, rotate_angle: float) -> Image:
	var rotated_image = Image.create(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8)
	rotated_image.fill(Color.TRANSPARENT)
	
	var center = Vector2(image.get_width() / 2.0, image.get_height() / 2.0)
	var cos_angle = cos(rotate_angle)
	var sin_angle = sin(rotate_angle)
	
	for x in range(image.get_width()):
		for y in range(image.get_height()):
			# 将像素坐标转换为相对于中心点的坐标
			var relative_x = x - center.x
			var relative_y = y - center.y
			
			# 应用旋转变换
			var new_x = relative_x * cos_angle - relative_y * sin_angle + center.x
			var new_y = relative_x * sin_angle + relative_y * cos_angle + center.y
			
			# 检查新坐标是否在图像范围内
			if new_x >= 0 and new_x < image.get_width() and new_y >= 0 and new_y < image.get_height():
				var pixel_color = image.get_pixel(int(new_x), int(new_y))
				rotated_image.set_pixel(x, y, pixel_color)
	
	return rotated_image.duplicate()

## 倾斜图像
static func _set_image_skew(image: Image, skew_angle: float) -> Image:
	var skewed_image = Image.create(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8)
	skewed_image.fill(Color.TRANSPARENT)
	
	var center_y = image.get_height() / 2.0
	var skew_factor = tan(skew_angle)
	
	for x in range(image.get_width()):
		for y in range(image.get_height()):
			# 计算倾斜偏移
			var skew_offset = (y - center_y) * skew_factor
			var source_x = x - skew_offset
			
			# 检查源坐标是否在图像范围内
			if source_x >= 0 and source_x < image.get_width():
				var pixel_color = image.get_pixel(int(source_x), y)
				skewed_image.set_pixel(x, y, pixel_color)
	
	return skewed_image.duplicate()

## 设置图像颜色
static func _set_image_color(image: Image, color: Color) -> Image:
	for x in range(image.get_width()):
		for y in range(image.get_height()):
			var pixel_color = image.get_pixel(x, y)
			if pixel_color.a > 0:  # 如果不是透明像素
				image.set_pixel(x, y, color)
	return image.duplicate()

## 缩放图像
static func _set_image_scale_size(image: Image, image_size: Vector2i) -> Image:
	image.resize(image_size.x, image_size.y)
	return image.duplicate()

static func _get_image_position(target_node: Node, target_position: Vector2, image_size: Vector2i) -> Vector2:
	if target_node is Control:
		var rect: Rect2 = target_node.get_global_rect()
		var image_position = target_position - rect.position - Vector2(image_size) / 2
		return image_position
	elif target_node is Sprite2D:
		if target_node.centered:
			var image_position = target_position - target_node.global_position - Vector2(image_size) / 2
			return image_position
		else:
			var image_position = target_position - target_node.global_position - Vector2(image_size) / 2
			return image_position
	else:
		return target_position - Vector2(image_size) / 2

static func _quick_blend_image(origin_image: Image, paint_image: Image, image_position: Vector2):
	origin_image.blend_rect(paint_image, Rect2i(Vector2i.ZERO, paint_image.get_size()), Vector2i(image_position))

#region 优化的图像处理 - 带缓存机制
# 图像处理缓存
static var _image_process_cache: Dictionary = {}
static var _max_cache_size: int = 100

## 优化的decal图像处理（带缓存）
## 这是一个高性能版本的图像处理方法，专门为decal系统优化
## [param source_image]: 原始图像
## [param angle]: 旋转角度（度数）
## [param scale_factor]: 缩放因子
## [param target_color]: 目标颜色
## [param target_size]: 目标尺寸，默认为Vector2i(64, 32)
## [br][br][b]返回:[/b] 处理后的图像
static func process_decal_image_cached(source_image: Image, angle: int, scale_factor: float, target_color: Color, target_size: Vector2i = Vector2i(64, 32)) -> Image:
	# 生成缓存键（使用图像大小和格式作为标识符）
	var cache_key = "%dx%d_%s_%d_%.2f_%s_%s" % [
		source_image.get_width(),
		source_image.get_height(),
		str(source_image.get_format()),
		angle,
		scale_factor,
		target_color.to_html(),
		str(target_size)
	]
	
	# 检查缓存
	if _image_process_cache.has(cache_key):
		return _image_process_cache[cache_key].duplicate()
	
	# 处理新图像
	var processed_image = _process_decal_image_optimized(source_image, angle, scale_factor, target_color, target_size)
	
	# 添加到缓存（管理缓存大小）
	_add_to_image_cache(cache_key, processed_image)
	
	return processed_image

## 内部优化的图像处理方法
static func _process_decal_image_optimized(source_image: Image, _angle: int, scale_factor: float, target_color: Color, target_size: Vector2i) -> Image:
	var processed = source_image.duplicate()
	
	# 1. 高效缩放
	var scaled_size = Vector2i(
		int(target_size.x * scale_factor),
		int(target_size.y * scale_factor)
	)
	processed.resize(scaled_size.x, scaled_size.y, Image.INTERPOLATE_LANCZOS)
	
	# 2. 优化的颜色处理 - 只处理非透明像素
	_apply_color_optimized(processed, target_color)
	
	# 3. 旋转处理（如果需要 - 暂时跳过复杂的旋转以提升性能）
	# 可以在这里添加简化的旋转逻辑
	
	return processed

## 优化的颜色应用
static func _apply_color_optimized(image: Image, color: Color):
	var width = image.get_width()
	var height = image.get_height()
	
	for x in range(width):
		for y in range(height):
			var pixel = image.get_pixel(x, y)
			if pixel.a > 0.1:  # 只处理非透明像素
				image.set_pixel(x, y, Color(color.r, color.g, color.b, pixel.a))

## 管理图像缓存
static func _add_to_image_cache(key: String, image: Image):
	# 如果缓存已满，清理最老的条目
	if _image_process_cache.size() >= _max_cache_size:
		_cleanup_image_cache()
	
	_image_process_cache[key] = image.duplicate()

## 清理图像缓存
static func _cleanup_image_cache():
	# 简单策略：清空一半缓存
	var half_cache_size = int(_max_cache_size * 0.5)
	var keys_to_remove = _image_process_cache.keys().slice(0, half_cache_size)
	for key in keys_to_remove:
		_image_process_cache.erase(key)

## 清空所有图像缓存（可用于内存管理）
static func clear_image_cache():
	_image_process_cache.clear()

## 获取缓存统计信息
static func get_cache_info() -> Dictionary:
	return {
		"cache_size": _image_process_cache.size(),
		"max_cache_size": _max_cache_size,
		"cache_usage": float(_image_process_cache.size()) / _max_cache_size
	}

#endregion

#region 兼容性方法 - 优化版本
## 优化的设置图像颜色（保持兼容性）
static func _set_image_color_optimized(image: Image, color: Color) -> Image:
	var result = image.duplicate()
	_apply_color_optimized(result, color)
	return result

## 优化的缩放图像（保持兼容性）
static func _set_image_scale_size_optimized(image: Image, image_size: Vector2i) -> Image:
	var result = image.duplicate()
	result.resize(image_size.x, image_size.y, Image.INTERPOLATE_LANCZOS)
	return result

#endregion
#endregion

#region 视图相关
# ## 从主视口坐标转换为子视口坐标
# ## 当使用SubViewport和SubViewportContainer时，get_global_mouse_position()会返回相对于主视口的位置
# ## 此函数将主视口坐标转换为子视口内的正确坐标
# ## 已修复：现在支持相机zoom缩放修正
# ## [param viewport_container]: 视口容器，类型为[SubViewportContainer]
# ## [param main_viewport_coords]: 主视口中的坐标位置，类型为[Vector2]
# ## [param camera]: 可选的相机引用，用于应用zoom缩放修正，类型为[Camera2D]
# ## [br][br][b]返回:[/b] 转换后的子视口坐标
# static func main_to_subviewport_coords(viewport_container: SubViewportContainer, main_viewport_coords: Vector2, camera: Camera2D = null) -> Vector2:
# 	# 1. 获取视口容器在主视口中的全局位置和尺寸
# 	var container_rect = viewport_container.get_global_rect()
	
# 	# 2. 计算鼠标在容器中的相对位置
# 	var local_coords = main_viewport_coords - container_rect.position
	
# 	# 3. 计算比例缩放因子（容器可能被缩放了）
# 	var viewport: SubViewport = viewport_container.get("viewport") as SubViewport
# 	if not viewport:
# 		return local_coords
	
# 	var scale_factor = Vector2(
# 		viewport.size.x / container_rect.size.x,
# 		viewport.size.y / container_rect.size.y
# 	)
	
# 	# 4. 应用缩放因子得到子视口中的正确坐标
# 	var viewport_pos = local_coords * scale_factor
	
# 	# 5. 应用相机zoom缩放修正（如果提供了相机引用）
# 	if camera and is_instance_valid(camera):
# 		var camera_zoom = camera.zoom
# 		if camera_zoom != Vector2.ZERO:
# 			var zoom_correction = Vector2(1.0 / camera_zoom.x, 1.0 / camera_zoom.y)
# 			var viewport_center = viewport.size * 0.5
# 			var offset_from_center = viewport_pos - viewport_center
# 			offset_from_center *= zoom_correction
# 			viewport_pos = viewport_center + offset_from_center
	
# 	return viewport_pos

# ## 获取正确的子视口鼠标位置
# ## 这是一个便捷方法，用于获取当前鼠标在子视口中的正确位置
# ## 特别适合用于分屏显示时获取鼠标位置
# ## 已修复：现在支持相机zoom缩放修正
# ## [param viewport_container]: 视口容器，类型为[SubViewportContainer]
# ## [param camera]: 可选的相机引用，用于应用zoom缩放修正，类型为[Camera2D]
# ## [br][br][b]返回:[/b] 在子视口中的鼠标坐标
# static func get_subviewport_mouse_position(viewport_container: SubViewportContainer, camera: Camera2D = null) -> Vector2:
# 	# 获取主视口中的鼠标位置
# 	var main_mouse_pos = viewport_container.get_viewport().get_mouse_position()
# 	# 转换为子视口坐标（包含zoom缩放修正）
# 	return main_to_subviewport_coords(viewport_container, main_mouse_pos, camera)


#endregion
