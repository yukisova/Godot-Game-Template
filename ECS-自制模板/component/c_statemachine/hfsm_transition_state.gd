@tool
class_name TransitionState
extends Resource

@export var keyword: StringName = ""

@export_node_path("Node") var from_state: NodePath:
	set(value):
		if value.is_empty():
			from_state = NodePath()
			return
			
		# 校验路径深度：直接子节点路径格式应为 "子节点名"
		if value.get_name_count() != 1:
			push_error("目标节点必须是直接子节点！")
			return
		if value == to_state:
			push_error("目标节点重名")
			return
			
		from_state = value
	get:
		return from_state

@export_node_path("Node") var to_state: NodePath:
	set(value):
		if value.is_empty():
			to_state = NodePath()
			return
			
		# 校验路径深度：直接子节点路径格式应为 "子节点名"
		if value.get_name_count() != 1:
			push_error("目标节点必须是直接子节点！")
			return
		
		if value == from_state:
			push_error("目标节点重名")
			return

		to_state = value
	get:
		return to_state
