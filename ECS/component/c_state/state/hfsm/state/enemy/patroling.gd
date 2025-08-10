## 敌人的巡逻状态，但需要
@tool
extends StateHfsm

@export var vector_move: MoveStrategy
@export var idle_time_range: Vector2 = Vector2(3.0, 5.0)
var idle_state_timer: Timer
@export var sight_box: SightBox


func _setup():
	super()
	sight_box.target_losed.connect(_on_target_losed)
	sight_box.target_noticed.connect(_on_target_noticed)
	
	idle_state_timer = Timer.new()
	idle_state_timer.one_shot = true
	idle_state_timer.timeout.connect(_on_try_patroling)
	add_child(idle_state_timer)

func _enter() -> void:
	idle_state_timer.start(randf_range(idle_time_range.x, idle_time_range.y))

func _blur_update(_delta: float) -> void:
	var _vector = vector_move.move_vector as Vector2

	if pda_state_stack.size() > 1:
		var top_state = pda_state_stack[-1] as StatePda
		match top_state.keyword:
			"target_lock":
				if top_state.plus_trigger:
					state_transition.emit(get_transition_state())
			"target_lost":
				if top_state.plus_trigger:
					state_pushed.emit()
	
func _on_target_losed(): ## 视野内没有目标时
	if belong_state_machine.current_state == self:
		var target_state = confirm_pda_state_dict["target_lost"]
		target_state.state_context["wait_time"] = 10
		state_pushed.emit(target_state)

func _on_target_noticed(): ## 视野内出现目标时
	if belong_state_machine.current_state == self:
		var target_state = confirm_pda_state_dict["target_lock"]
		target_state.state_context["wait_time"] = 4
		state_pushed.emit(target_state)

func _on_try_patroling():
	if pda_state_stack.size() == 1:
		state_pushed.emit(confirm_pda_state_dict["random_patrol"])
