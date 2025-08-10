@tool
extends StateHfsm

@export var sight_box: SightBox

func _setup():
	super()
	sight_box.target_losed.connect(_on_target_losed)
	sight_box.target_noticed.connect(_on_target_noticed)

func _on_target_losed(): ## 视野内没有目标时
	if belong_state_machine.current_state == self:
		state_pushed.emit(confirm_pda_state_dict["target_lost"])

func _on_target_noticed(): ## 视野内出现目标时
	if belong_state_machine.current_state == self:
		state_pushed.emit(confirm_pda_state_dict["target_lock"])
