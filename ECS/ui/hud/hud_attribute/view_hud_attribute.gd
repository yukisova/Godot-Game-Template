extends UIView

@export var health_bar: ProgressBar
@export var sound_bar: ProgressBar
@export var fitness_bar: ProgressBar
@export var left_hand_texture: TextureRect
@export var right_hand_texture: TextureRect

@export var seek_state: TextureRect

func _on_health_changed(value: float, _max: float):
	health_bar.value = value
	health_bar.max_value = _max

func _on_sound_changed(value: float, _max: float):
	sound_bar.value = value
	sound_bar.max_value = _max

func _on_fitness_changed(value: float, _max: float):
	fitness_bar.value = value
	fitness_bar.max_value = _max

func _on_weapon_changed(value: Texture2D):
	left_hand_texture.texture = value

func _on_equipment_changed(value: Texture2D):
	right_hand_texture.texture = value

func _on_seek_state_changed(state: bool):
	if state:
		seek_state.self_modulate = Color.RED
	else:
		seek_state.self_modulate = Color.WHITE
