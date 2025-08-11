## FIXME 测试用，打算使用战争迷雾系统来代替原本的房屋系统实现战争迷雾，而非借助硬性的框选截取
extends Sprite2D

@export var fog_width: int
@export var fog_height: int
var fog_image: Image
var fog_texture: ImageTexture

@export var light_texture: Texture2D
var light_image: Image

var player: CharacterBody2D

func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

func _initialize():
	player = SMainController.player_static.main_control
	
	fog_image = Image.create(fog_width, fog_height, false, Image.FORMAT_RGBA8)
	fog_image.fill(Color.WHITE) ## 测试: 一开始先填充白色作为底色
	fog_texture = ImageTexture.create_from_image(fog_image)
	texture = fog_texture
	
	light_image = light_texture.get_image()
	update_fog()
	process_mode = Node.PROCESS_MODE_INHERIT
	## 以下是一个不知原因的小bug， 
	#hide()
	#show()

func _process(delta: float) -> void:
	if !player.velocity.is_equal_approx(Vector2.ZERO):
		update_fog()

func update_fog():
	var player_position = player.global_position + Vector2(fog_width, fog_height) / 2
	player_position -= Vector2(light_image.get_size()) / 2.0
	
	fog_image.blend_rect(light_image, Rect2i(Vector2.ZERO, light_image.get_size()), player_position)
	fog_texture.update(fog_image)

#region :存档系统:
func _save_as():
	pass

func _load_by():
	pass
#endregion