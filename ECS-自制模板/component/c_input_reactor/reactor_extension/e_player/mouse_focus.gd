extends ReactorExtension

@export var mouse_focus: Array[Node2D]

func _listen():
	for i in mouse_focus:
		i.global_position = i.get_global_mouse_position()
