@tool
extends StatePda

var _current_time: float = 0

func _enter_tree() -> void:
	keyword = "target_lost"

func _enter():
	print("哥布林突然丢失目标")
	_current_time = 0

func _update(_delta: float):
	_current_time += _delta
	var wait_time = state_context.get_or_add("wait_time", 10)
	if _current_time > wait_time:
		pop_trigger = true ## 已经丢失了目标，退出状态
