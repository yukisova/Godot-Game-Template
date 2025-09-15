extends TextureRect

@export var paint: Texture2D

func _ready() -> void:
	var image = Image.create(1000, 1000, false, Image.FORMAT_RGBA8)
	
	texture = ImageTexture.create_from_image(image)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_try_paint(get_global_mouse_position())

## 尝试绘制血迹

func _try_paint(_global_position: Vector2):
	# 将世界坐标转换为相对于TextureRect的本地坐标
	# 使用get_global_rect()获取TextureRect的全局矩形区域
	var rect = get_global_rect()
	var paint_image = paint.get_image()
	
	# 将256x256的纹理缩放到64x64进行混合
	var scaled_paint_image = paint_image.duplicate()
	

	scaled_paint_image = SoraEvent._set_image_scale_size(scaled_paint_image, Vector2(64, 64))
	var image_position = SoraEvent._get_image_position(rect, _global_position, Vector2(64, 64))

	# 应用随机变形和倾斜效果
	# var random_rotation = randf_range(-PI/6, PI/6)  # -30度到30度随机旋转
	# var random_skew = randf_range(-0.3, 0.3)       # 随机倾斜角度
	var origin_image = texture.get_image()
	origin_image.blend_rect(scaled_paint_image, Rect2i(Vector2i.ZERO, scaled_paint_image.get_size()), Vector2i(image_position))
	(texture as ImageTexture).set_image(origin_image)