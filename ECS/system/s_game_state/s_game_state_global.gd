extends ISystem

@export var state_machine: StateMachine

var is_setup = false

func _setup():
	state_machine._setup()
	state_machine._enter()
	is_setup = true

func _process(delta: float) -> void:
	if is_setup:
		state_machine._update(delta)

func _physics_process(delta: float) -> void:
	if is_setup:
		state_machine._fixed_update(delta)

func get_current_state() -> IState:
	return state_machine.get_leaf_state()