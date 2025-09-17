## 手电筒的装备节点
@tool
extends EquipmentNode

enum FlashlightMode {
	SPREAD, ## 散射
	STREAM, ## 直射散光
	SHOOTING, ## 直射聚光
}

var flashlight_mode: FlashlightMode = FlashlightMode.SHOOTING
var flashlight_texture: ImageTexture
@export var point_light: PointLight2D

func _ready() -> void:
	flashlight_texture = ImageTexture.create_from_image(Image.create(1, 1, false, Image.FORMAT_RGBA8))
	point_light.flash_light_mode = flashlight_mode
	point_light.c_status = c_status
