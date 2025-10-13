## 手电筒的装备节点
@tool
extends EquipmentNode

var flashlight_texture: ImageTexture

@export var point_light: PointLight2D

var timer: Timer

func _ready() -> void:
	flashlight_texture = ImageTexture.create_from_image(Image.create(1, 1, false, Image.FORMAT_RGBA8))
	point_light.c_status = c_status

func _trigger_effect_run(..._args) -> bool:
	timer.wait_time = 0.1
	timer.one_shot = false

	timer.timeout.connect(trigger_effect_success)
	return true

func _trigger_effect_finish(..._args):
	timer.stop()
	pass
## 装备在普通状态下的状态:

## 装备在普通状态下的状态:

func _activated():
	pass

func _deactivated():
	pass

func trigger_effect_success():
	pass

func set_normal_type():
	point_light.flash_light_mode = 0

func set_aim_type():
	point_light.flash_light_mode = 1
