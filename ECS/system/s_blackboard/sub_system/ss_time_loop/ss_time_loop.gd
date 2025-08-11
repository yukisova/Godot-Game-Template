## @editing: Sora [br]
## @describe: 时间子系统
class_name SSTimeLoop
extends SubSystem

signal time_updated(time: int)

var past_time: int
var real_time: int:
	set(v):
		real_time = v % 1440
		time_updated.emit(real_time)
		SMapData.current_map.filter_changed.emit(real_time / 1440.0)

@export_range(0, 1440) var start_time: int

func _enter_tree() -> void:
	keyword = &"time_loop"

#region 时间系统的实现
func _setup():
	@warning_ignore("integer_division")
	past_time = Time.get_ticks_msec() / 1000
	real_time = start_time

func _update(_delta: float) -> void:
	@warning_ignore("integer_division")
	var current_time = Time.get_ticks_msec() / 1000
	if current_time != past_time:
		past_time = current_time
		if SGameState.state_machine._get_leaf_state() is GamingStateNormal:
			real_time += 1

#endregion

#region :存档系统，将黑板的信息全部保存下来:
func _save_as() -> Dictionary:
	var result = {}
	result["real_time"] = real_time
	return {
		keyword:result
	}

func _load_by():
	pass
#endregion