extends UIView

@export var text_prototype: Label

func update_blank_text(target_text: String, dict: Dictionary):
	var new_text = text_prototype.duplicate()
	new_text.text = target_text
	new_text.material = text_prototype.material.duplicate_deep()
	new_text.position = Vector2(dict.get("x", 0), dict.get("y", 0))
	
	new_text.add_theme_font_size_override("font_size", (dict.get("font_size", 16)))
	new_text.material.set_shader_parameter("lod", 1.0)
	add_child(new_text)
	
	var tween = get_tree().create_tween()
	tween.tween_method(_set_lod.bind(new_text), 1.0, 0.0, dict.get("start_duration", 0.5))
	tween.tween_method(_set_lod.bind(new_text), 0.0, 1.0, dict.get("end_duration", 0.5)).set_delay(dict.get("keep_duration",3))
	tween.tween_callback(Callable(func(label: Label): label.queue_free()).bind(new_text))

func _set_lod(lod: float,target_label: Label):
	target_label.material.set_shader_parameter("lod", lod)
