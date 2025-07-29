## @editing:	 Sora
## @describe: 状态机组件
@tool
class_name C_State
extends IComponent

@export var root_state_machine: StateMachineHfsm
@export var pda_states: Node
var pda_state_dict: Dictionary[StringName, StatePda]

func _enter_tree() -> void:
	component_name = ComponentName.c_state
	
	for i in pda_states.get_children():
		pda_state_dict[i.keyword] = i

func _initialize(_owner: Entity):
	super._initialize(_owner)
	
	root_state_machine._enter()
	root_state_machine._setup()

func _update(_delta: float):
	root_state_machine._update(_delta)

func _fixed_update(_delta: float):
	root_state_machine._fixed_update(_delta)
