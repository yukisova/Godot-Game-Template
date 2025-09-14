extends TextureRect

@export var paint: Texture2D

func _ready() -> void:
	var image = Image.create(1000, 1000, false, Image.FORMAT_RGBA8)
	
	texture = ImageTexture.create_from_image(image)

func _process(_delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_try_paint(get_global_mouse_position())

func _try_paint(_global_position: Vector2):
	# 将世界坐标转换为相对于TextureRect的本地坐标
	# 使用get_global_rect()获取TextureRect的全局矩形区域
	var rect = get_global_rect()
	var image_position = _global_position - rect.position - paint.get_size() / 2
	var paint_image = paint.get_image()
	var origin_image = texture.get_image()
	origin_image.blend_rect(paint_image, Rect2i(Vector2i.ZERO, paint_image.get_size()), Vector2i(image_position))
	(texture as ImageTexture).set_image(origin_image)
