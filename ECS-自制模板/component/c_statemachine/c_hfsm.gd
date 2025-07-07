@tool
class_name C_Hfsm
extends IComponent

@export var root_state_machine: StateMachine

func _initialize(_owner: Entity):
	super._initialize(_owner)
	root_state_machine._enter()
	root_state_machine._setup()

func _update(delta: float):
	var input = get_controller();
	if input != null:
		_try_control(input)
	
	root_state_machine._update(delta)

func _fixed_update(delta: float):
	root_state_machine._fixed_update(delta)

func _try_control(_controller: IComponent):
	if Main.s_game_state.state_machine._get_leaf_state() is GamingStateNormal and _controller.is_main_controller:
		_controller._ui_trigger()
