extends Action

@export var c_animation: IComponent

func _effect(..._args):
	
	var sprite = c_animation.get("base_sprite") as Node2D
	var _material = sprite.material
	_material.set_shader_parameter("shake_intensity", 0.5)
	await get_tree().create_timer(1.0).timeout
	_material.set_shader_parameter("shake_intensity", 0.0)
