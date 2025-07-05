@tool
class_name StateMachine
extends State

@export var transition_list: Array[TransitionState]
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

var current_state: State


func _setup() -> void:
	for i in get_children():
		if i is State:
			i.state_transition.connect(_on_state_transition)
			if i is StateMachine:
				i._setup()

func _on_state_transition(from: NodePath, transition_keyword: StringName = ""):
	var filter_result = transition_list.filter(func(a: TransitionState): return a.keyword == transition_keyword && a.from_state == from)
	if (filter_result.size() > 0):
		var a = filter_result[0] as TransitionState
		var to_state = get_node(a.to_state) as State
		current_state._exit()
		current_state = to_state
		current_state._enter()
	else:
		printerr("节点%s不存在关键字为%s的过渡" % [from.get_concatenated_names(), transition_keyword])
	transition_finished.emit()

func _enter():
	current_state = get_node(init_state)
	current_state._enter()

func _fixed_update(delta: float) -> void:
	current_state._fixed_update(delta)

func _update(delta: float) -> void:
	current_state._update(delta)

func _get_active_state() -> State:
	return current_state

func _get_leaf_state() -> State:
	var result = current_state
	
	while result is StateMachine:
		result = result.current_state
	
	return result
