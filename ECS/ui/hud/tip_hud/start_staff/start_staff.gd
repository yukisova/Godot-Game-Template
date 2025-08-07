extends Control

var current_index = 0
@export var label_list: Array[Label]

func _ready() -> void:
	for i:Label in get_children():
		i.modulate.a = 0
	start()

func start():
	await _running()
	await _running()
	await _running()


func _running():
	var tween = get_tree().create_tween()
	if current_index < label_list.size():
		tween.tween_property(label_list[current_index],"modulate:a", 1.0, 1.0)
		tween.tween_property(label_list[current_index],"modulate:a", 0.0, 1.0).set_delay(3.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	current_index += 1
	await tween.finished
	
