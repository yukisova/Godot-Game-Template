extends IHud

@export var black_rect: ColorRect

func _initialize():
	pass

func _refresh():
	pass

func fade_in():
	var tween = get_tree().create_tween()
	tween.tween_property(black_rect, "modulate", Color(0,0,0,0), 1.5)
	await tween.finished

func fade_out():
	var tween = get_tree().create_tween()
	tween.tween_property(black_rect, "modulate", Color(0,0,0,1), 1.5)
	await tween.finished
