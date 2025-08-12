## @editing: Sora [br]
## @describe: 游戏的状态机系统
extends ISystem

signal game_paused
signal game_continue

@export var state_machine: StateMachineHfsm
var is_setup = false

func _setup():
	state_machine._setup()
	state_machine._enter()
	is_setup = true

func _resetup():
	pass

func _process(delta: float) -> void:
	if is_setup:
		state_machine._update(delta)

func _physics_process(delta: float) -> void:
	if is_setup:
		state_machine._fixed_update(delta)
