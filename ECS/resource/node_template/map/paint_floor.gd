## 血迹地板
## 用于绘制血迹地板
## [br][b]编辑者:[/b] Sora
class_name PaintFloor
extends TextureRect

func _initialize():
	var limit_size = (get_parent() as Control).size
	var origin_image = Image.create_empty(limit_size.x, limit_size.y, false, Image.FORMAT_RGBA8)
	origin_image.fill(Color.TRANSPARENT)
	texture = ImageTexture.create_from_image(origin_image)
