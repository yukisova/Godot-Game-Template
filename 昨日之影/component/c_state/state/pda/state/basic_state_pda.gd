## @editing: Sora \
## @describe: 基础的头栈，演示用
@tool
extends StateHfsm

@export var label: Label
@export var text: String

func _enter():
	label.text = text 
	## 等待数秒时间继续巡逻
	await get_tree().create_timer(3.0).timeout
	state_transition.emit(get_transition_state())

func _exit():
	pass
	
