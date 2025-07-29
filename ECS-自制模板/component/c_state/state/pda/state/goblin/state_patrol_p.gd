## @editing: Sora \
## @describe: 
@tool
extends StateHfsm

## 巡逻区域，若敌人是批量生成的话需要在BlackBoard中获取目标的patrol_zone
@export_node_path("Path2D", "Area2D") var patrol_zone: NodePath

@export var label: Label
@export var text: String

var wait_timer: Timer

func _ready() -> void:
	wait_timer = Timer.new()
	wait_timer.one_shot = true
	add_child(wait_timer)

func _enter():
	label.text = text 
	
	wait_timer.start()

func _update(_delta: float) -> void:
	if wait_timer.is_stopped():
		state_transition.emit(get_transition_state())

func _fixed_update(_delta: float) -> void:
	pass

func _exit():
	pass
