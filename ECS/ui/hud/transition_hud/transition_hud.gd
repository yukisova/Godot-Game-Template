extends IHud

@export var black_rect: ColorRect

func _initialize():
	black_rect.modulate = Color(0,0,0,0)

func _refresh():
	black_rect.modulate = Color(0,0,0,0)


func fade_in():
	var tween = get_tree().create_tween()
	tween.tween_property(black_rect, "modulate", Color(0,0,0,0), 1.5)

func fade_out():
	var tween = get_tree().create_tween()
	tween.tween_property(black_rect, "modulate", Color(0,0,0,1), 1.5)
