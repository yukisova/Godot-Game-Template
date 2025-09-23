@tool
class_name CStateMachine
extends IComponent

@export var root_state_machine: StateMachine
@export var stack_states: Node
@export var temp_states: Node

var stack_state_dict: Dictionary[StringName, StatePda]

func _enter_tree() -> void:
	component_name = ComponentName.C_STATE_MACHINE

func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)
	
	# 连接游戏暂停信号
	SSignalBus.game_loop_paused.connect(_pause)
	# 连接游戏继续信号
	SSignalBus.game_loop_continue.connect(_continue)
	
	for child in stack_states.get_children():
		if child is StatePda:
			stack_state_dict[child.keyword] = child

	if root_state_machine:
		root_state_machine.is_root = true
		root_state_machine._setup()
		root_state_machine._enter()
	else:
		push_warning("状态机组件: 实体 ", component_owner.name, " 缺少根状态机")
	
	initialize_completed.emit()

func _update(_delta: float):
	if root_state_machine:
		root_state_machine._update(_delta)

func _fixed_update(_delta: float):
	if root_state_machine:
		root_state_machine._fixed_update(_delta)

func _pause():
	if root_state_machine:
		root_state_machine._pause()

func _continue():
	if root_state_machine:
		root_state_machine._continue()

func get_stack_state(keyword: StringName) -> StatePda:
	return stack_state_dict.get(keyword)

func get_current_state():
	if root_state_machine:
		return root_state_machine.get_leaf_state()
	return null
