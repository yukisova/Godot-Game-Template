@tool
extends PointLight2D

enum FlashLightMode{
	WALK,
	SPREAD,
	SHOOT,
}

@export var flash_light_mode: FlashLightMode = FlashLightMode.SHOOT

@export var flashlight_radius: float = 20
@export var light_radius: float = 40.0
@export var light_length: float = 100.0

@export var image_padding: float = 10
@export var triangle_color: Color = Color.WHITE

var c_status: CStatusList

#func _ready() -> void:
	#if Engine.is_editor_hint(): return
	#texture = create_triangle_texture()

func _process(_delta: float) -> void:
	#if Engine.is_editor_hint(): return
	match flash_light_mode:
		FlashLightMode.WALK:
			pass
		FlashLightMode.SPREAD:
			pass
		FlashLightMode.SHOOT:
			_shoot_mode_process(_delta)

## 直射模式 - 使用梯形纹理和两个圆形纹理
func _shoot_mode_process(_delta: float) -> void:
	var mouse_pos
	if Engine.is_editor_hint():
		mouse_pos = get_global_mouse_position()
	else:
		if !c_status:
			return
		mouse_pos = SoraEvent.fixed_mouse_position(c_status.component_body)["world_mouse_pos"]
		print(mouse_pos)
	rotation = global_position.direction_to(mouse_pos).angle()
	
	light_length = global_position.distance_to(mouse_pos) + light_radius

	offset = Vector2((-light_radius+light_length)/2, 0)

	# 创建梯形纹理和两个圆形纹理
	var start_light: Image = create_circle_texture_start()
	var trapezoid_light: Image = create_trapezoid_texture()
	var spot_light: Image = create_circle_texture_end()

	# 将起始圆形纹理混合到梯形纹理上（在梯形的起始端，考虑padding偏移）
	var start_offset_x = int(light_radius + image_padding - start_light.get_width() * 0.5)
	var start_offset_y = int(light_radius + image_padding - start_light.get_height() * 0.5)
	trapezoid_light.blend_rect(
		start_light, 
		Rect2i(Vector2.ZERO, start_light.get_size()), 
		Vector2i(start_offset_x, start_offset_y)
	)
	
	# 将终点圆形纹理混合到梯形纹理上（在梯形的终点端，考虑padding偏移）
	var end_offset_x = 0  # 终点圆形已经在正确位置（包含padding）
	var end_offset_y = 0  # 终点圆形已经在正确位置
	trapezoid_light.blend_rect(
		spot_light, 
		Rect2i(Vector2i(end_offset_x, end_offset_y), spot_light.get_size()), 
		Vector2i(end_offset_x, end_offset_y)
	)

	texture.set_image(trapezoid_light)

#region 创建三角形纹理
func create_triangle_texture() -> Image:
	# 创建一个新的图像（加上padding）
	var image_width = int(light_length + light_radius + image_padding * 2)
	var image_height = int(light_radius * 2 + image_padding * 2)
	var image = Image.create(image_width, image_height, false, Image.FORMAT_RGBA8)
	
	# 填充透明背景
	image.fill(Color(0, 0, 0, 0))
	
	# 计算三角形顶点坐标（向上指向的三角形，加上padding偏移）
	var vertex3 = Vector2(light_length + image_padding, light_radius * 2 + image_padding)
	var vertex2 = Vector2(light_length + image_padding, image_padding)
	var vertex1 = Vector2(light_radius + image_padding, light_radius + image_padding)
	
	# 绘制三角形
	draw_triangle_on_image(image, vertex1, vertex2, vertex3, triangle_color)
	
	# 创建并返回 Image
	return image

func draw_triangle_on_image(image: Image, v1: Vector2, v2: Vector2, v3: Vector2, fill_color: Color) -> void:
	# 使用扫描线算法填充三角形
	var min_y = int(floor(min(v1.y, min(v2.y, v3.y))))
	var max_y = int(ceil(max(v1.y, max(v2.y, v3.y))))
	
	# 确保y范围在图像边界内
	min_y = max(0, min_y)
	max_y = min(image.get_height() - 1, max_y)
	
	for y in range(min_y, max_y + 1):
		var intersections = []
		
		# 检查与三条边的交点
		add_edge_intersection(intersections, v1, v2, float(y))
		add_edge_intersection(intersections, v2, v3, float(y))
		add_edge_intersection(intersections, v3, v1, float(y))
		
		# 移除重复的交点并排序
		var unique_intersections = []
		intersections.sort()
		for x_val in intersections:
			if unique_intersections.is_empty() or abs(x_val - unique_intersections[-1]) > 0.5:
				unique_intersections.append(x_val)
		
		# 确保有偶数个交点
		if unique_intersections.size() % 2 != 0:
			continue
			
		# 填充像素
		for i in range(0, unique_intersections.size(), 2):
			if i + 1 < unique_intersections.size():
				var x_start = int(floor(unique_intersections[i]))
				var x_end = int(ceil(unique_intersections[i + 1]))
				
				# 确保x范围在图像边界内
				x_start = max(0, x_start)
				x_end = min(image.get_width() - 1, x_end)
				
				for x in range(x_start, x_end + 1):
					image.set_pixel(x, y, fill_color)

func add_edge_intersection(intersections: Array, p1: Vector2, p2: Vector2, y: float) -> void:
	# 如果边是水平的，跳过
	if abs(p1.y - p2.y) < 0.001:
		return
	
	# 检查 y 是否在边的范围内（包含端点）
	var min_y = min(p1.y, p2.y)
	var max_y = max(p1.y, p2.y)
	
	if y < min_y - 0.001 or y > max_y + 0.001:
		return
	
	# 计算交点的 x 坐标
	var t = (y - p1.y) / (p2.y - p1.y)
	var x = p1.x + (p2.x - p1.x) * t
	intersections.append(x)
#endregion

#region 创建梯形纹理
## 创建梯形纹理 - 手电筒光束形状
func create_trapezoid_texture() -> Image:
	# 创建图像，尺寸加上padding
	var image_width = int(light_length + light_radius + image_padding * 2)
	var image_height = int(light_radius * 2 + image_padding * 2)
	var image = Image.create(image_width, image_height, false, Image.FORMAT_RGBA8)
	
	# 填充透明背景
	image.fill(Color(0, 0, 0, 0))
	
	# 定义梯形的四个顶点（加上padding偏移）
	# 起始端较窄，终点端较宽
	var start_width = flashlight_radius*2# 起始端宽度
	var end_width = light_radius         # 终点端宽度
	var length = light_length            # 长度
	
	# 梯形四个顶点坐标（加上padding偏移）
	var v1 = Vector2(light_radius + image_padding, light_radius - start_width/2 + image_padding)  # 左上
	var v2 = Vector2(light_radius + image_padding, light_radius + start_width/2 + image_padding)  # 左下
	var v3 = Vector2(length + image_padding, light_radius + end_width + image_padding)          # 右下
	var v4 = Vector2(length + image_padding, light_radius - end_width + image_padding)          # 右上
	
	# 绘制梯形（通过两个三角形组合）
	draw_triangle_on_image(image, v1, v2, v3, triangle_color)
	draw_triangle_on_image(image, v1, v3, v4, triangle_color)
	
	# 创建并返回 ImageTexture
	return image
#endregion

#region 创建圆形纹理
# 创建圆形纹理 聚光点
func create_circle_texture_end() -> Image:
	var image_width = int(light_radius + light_length + image_padding * 2)
	var image_height = int(light_radius * 2 + image_padding * 2)
	var image = Image.create(image_width, image_height, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	draw_circle_on_image(image, Vector2(light_length + image_padding, light_radius + image_padding), light_radius, Color.WHITE)
	return image

# 创建圆形纹理 起始点 - 与梯形起始端匹配
func create_circle_texture_start() -> Image:
	var image_size = int(light_radius * 2 + image_padding * 2)
	var image = Image.create(image_size, image_size, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	draw_circle_on_image(image, Vector2(light_radius + image_padding, light_radius + image_padding), flashlight_radius, Color.WHITE)
	return image

func draw_circle_on_image(image: Image, center: Vector2, radius: float, fill_color: Color) -> void:
	# 使用扫描线算法直接填充圆形
	var cx = center.x
	var cy = center.y
	var r = radius
	var r_squared = r * r
	
	# 计算扫描范围
	var start_y = int(floor(cy - r))
	var end_y = int(ceil(cy + r))
	
	# 确保在图像边界内
	start_y = max(0, start_y)
	end_y = min(image.get_height() - 1, end_y)
	
	# 逐行扫描填充
	for y in range(start_y, end_y + 1):
		var dy = y - cy
		var dy_squared = dy * dy
		
		# 如果这一行与圆形有交点
		if dy_squared <= r_squared:
			var dx = sqrt(r_squared - dy_squared)
			var x_start = int(floor(cx - dx))
			var x_end = int(ceil(cx + dx))
			
			# 确保x坐标在图像边界内
			x_start = max(0, x_start)
			x_end = min(image.get_width() - 1, x_end)
			if x_start > x_end:
				continue
			# 填充这一行的像素
			for x in range(x_start, x_end+1):
				image.set_pixel(x, y, fill_color)
#endregion
