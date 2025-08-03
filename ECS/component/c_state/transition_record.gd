## @editing: Sora [br]
## @describe: 可过渡状态记录类(放在状态而非放在状态机中)
@tool
class_name TrainsitionRecord
extends Resource

## 过渡到的目标状态, 要求状态属于[StateHfsm]，且必须是兄弟节点
@export_node_path("StateHfsm") var to_state: NodePath:
	set(value):
		if value.is_empty():
			to_state = NodePath()
			return

		# 校验路径深度：直接子节点路径格式应为 "子节点名"
		var str_value = value as String
		if !str_value.begins_with("../") or value.get_name_count() != 2:
			push_error("目标节点必须是兄弟节点！信息: %s, %s" % [value.get_name_count(),value])
			return

		to_state = value
	get:
		return to_state
