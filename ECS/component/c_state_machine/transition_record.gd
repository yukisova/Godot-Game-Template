## 状态转换记录类 - 定义状态间的转换关系和验证规则
## 用于配置状态机中状态之间的转换关系，提供路径验证和兄弟节点约束
## 设计特点：基于节点路径的状态引用、严格的兄弟节点验证、编辑器友好配置
## 使用场景：HFSM状态机转换配置、状态跳转关系定义、复杂状态机结构管理
## [br][b]编辑者:[/b] Sora
@tool
class_name TrainsitionRecord
extends Resource

## 过渡到的目标状态，要求状态属于 StateHfsm类型，且必须是兄弟节点
## 路径格式必须为 "../状态名"
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
