@tool
extends StatePda

@export var sight_box: SightBox

var _current_time: float = 0.0:
	set(v):
		if v < 0:
			_current_time = 0
		else:
			_current_time = v
var muti: float = 1.0

func _enter_tree() -> void:
	keyword = "target_lock"
	blur_update_enable = true

func _enter():
	_current_time = 0.0

func _update(_delta: float) -> void:
	#if sight_box.sight_target.is_empty():
	
	var lock_target_position: Vector2
	if sight_box.sight_target.is_empty():
		lock_target_position = sight_box.sight_target_last_position
	else:
		lock_target_position = sight_box.sight_target[-1].global_position
	
	sight_box.rotation = lerp_angle(sight_box.rotation, sight_box.global_position.direction_to(lock_target_position).angle(), _delta * 10)
	_current_time += muti * _delta
	var wait_time = state_context.get_or_add("wait_time", 4)
	if _current_time > wait_time:
		plus_trigger = 0

func _blur_update(_delta: float):
	_current_time -= _delta
