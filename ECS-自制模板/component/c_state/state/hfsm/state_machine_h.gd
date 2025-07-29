##@editing:	Sora
##@describe:	基于Hfsm的状态机类，本身也属于一个状态，基于此实现多层有限状态机
@tool
class_name StateMachineHfsm
extends StateHfsm

signal state_transition_finished

@export_node_path() var init_state: NodePath:
	set(value):
		if value.is_empty():
			init_state = NodePath()
			return
			
		# 校验路径深度：直接子节点路径格式应为 "子节点名"
		if value.get_name_count() != 1:
			push_error("目标节点必须是直接子节点！")
			return
			
		init_state = value
	get:
		
		if get_child_count() == 0:
			#push_error("状态机 %s没有状态用于初始化" % [name])
			return ""
		elif init_state == null:
			return get_path_to(get_child(0))
		else:
			return init_state

var current_state: StateHfsm

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		notify_property_list_changed()

func _setup() -> void:
	for i in get_children():
		if i is StateHfsm:
			i.state_transition.connect(_on_state_transition)
			i._setup()

func _on_state_transition(to_state: StateHfsm):
	var from_state = current_state
	from_state._clear_stack_and_exit()
	if to_state != from_state:
		current_state = to_state
		current_state._enter()
	else:
		push_error("不可与自身进行过渡")
	state_transition_finished.emit()

func _enter():
	current_state = get_node(init_state)
	current_state._enter()

func _fixed_update(delta: float) -> void:
	current_state._f_u(delta)

func _update(delta: float) -> void:
	_listen()
	current_state._u(delta)

func _get_active_state() -> StateHfsm:
	return current_state

func _get_leaf_state() -> StateHfsm:
	var result = current_state
	
	while result is StateMachineHfsm:
		result = result.current_state
	
	return result
