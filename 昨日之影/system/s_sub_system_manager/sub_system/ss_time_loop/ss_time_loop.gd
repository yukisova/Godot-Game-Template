## @editing: Sora [br]
## @describe: 时间子系统
class_name SSTimeLoop
extends SubSystem

signal time_updated(time: int)
signal time_important_coming(record_keyword: String)

var past_time: int
var real_time: int:
	set(v):
		real_time = v % 1440
		time_updated.emit(real_time)
		compare_time_record(real_time)
		SMapData.current_map.filter_changed.emit(real_time / 1440.0)

@export var time_record: Array[TimeRecord]

@export_range(0, 1440) var start_time: int

func _enter_tree() -> void:
	keyword = &"time_loop"

## 对当前的使用
func compare_time_record(current_time: int):
	for record in time_record:
		@warning_ignore("integer_division")
		if record.target_hour == current_time / 60:
			if record.target_minute == current_time % 60:
				time_important_coming.emit(record.target_event_keyword)

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
