@tool
class_name StackTransition
extends Resource

@export var keyword: StringName = ""
enum TransitionType { SWITCH, PUSH, POP }
@export var transition_type: TransitionType = TransitionType.SWITCH
@export_node_path("State") var push_target: NodePath:  # PUSH操作的目标状态
	set(value):
		if value.is_empty():
			push_target = NodePath()
			return
		if value.get_name_count() != 1:
			push_error("目标节点必须是直接子节点")
		push_target = value
