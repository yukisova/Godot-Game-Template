## 血迹地板
## 用于绘制血迹地板
## [br][b]编辑者:[/b] Sora
class_name PaintFloor
extends TextureRect

func _initialize():
	var limit_size = (get_parent() as Control).size
	var origin_image = Image.create(limit_size, limit_size, false, Image.FORMAT_RGBA8)
	origin_image.fill(Color.TRANSPARENT)
	texture = ImageTexture.create_from_image(origin_image)
	
## 血液飞溅
func splash_blood(_global_position: Vector2, blood_image: Image):
	var position_in_image = _global_position - texture.get_size() / 2 + Vector2(blood_image.get_size()) / 2
	var origin_image = texture.get_image()
	origin_image.blend_rect(blood_image, Rect2i(Vector2.ZERO, blood_image.get_size()), Vector2i(position_in_image))
	texture.update(origin_image)
