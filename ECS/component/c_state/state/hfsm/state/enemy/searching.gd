## 敌人的注意到了玩家，尝试进行进一步的确认
## 1. target

@tool
extends StateHfsm

@export var sight_box: SightBox
var idle_state_timer: Timer

func _setup():
	super()
	sight_box.target_losed.connect(_on_target_losed)
	sight_box.target_noticed.connect(_on_target_noticed)
	
	idle_state_timer = Timer.new()
	idle_state_timer.one_shot = true
	idle_state_timer.timeout.connect(_on_try_searching)
	add_child(idle_state_timer)


func _on_target_losed(): ## 视野内没有目标时
	if belong_state_machine.current_state == self:
		var target_state = confirm_pda_state_dict["target_lost"]
		target_state.state_context["wait_time"] = 30
		state_pushed.emit(target_state)

func _on_target_noticed(): ## 视野内出现目标时
	if belong_state_machine.current_state == self:
		var target_state = confirm_pda_state_dict["target_lock"]
		target_state.state_context["wait_time"] = 2
		state_pushed.emit(target_state)

func _on_try_searching():
	pass
