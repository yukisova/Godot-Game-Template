extends Control

@export var fade_duration:float = 0.5
@export var stay_duration:float = 1
@export var display_logos:Array[Control]
@export var real_launcher:PackedScene
@export var interuptable:bool = true

func _enter_tree() -> void:
	for i in display_logos: 
		i.modulate.a = 0.0

func _ready():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(display_logos[0], "modulate:a", 1.0, fade_duration)\
		.from(0.0)
	tween.tween_property(display_logos[0], "modulate:a", 0.0, fade_duration)\
		.set_delay(stay_duration)
	tween.tween_property(display_logos[1], "modulate:a", 1.0, fade_duration)\
		.from(0.0)
	tween.tween_property(display_logos[1], "modulate:a", 0.0, fade_duration)\
		.set_delay(stay_duration)\
		.finished.connect(_change_scene)
		
	
func _process(_delta):
	if interuptable and Input.is_action_just_pressed("ui_accept"):
		_change_scene()

func _change_scene():
	get_tree().change_scene_to_packed(real_launcher)
