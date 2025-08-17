## 状态转换记录类 - 定义状态间的转换关系和验证规则
##
## 该资源类用于配置状态机中状态之间的转换关系。
## 提供路径验证和兄弟节点约束，确保状态转换的正确性。
##
## 设计特点：
## - 基于节点路径的状态引用系统
## - 严格的兄弟节点验证机制
## - 编辑器友好的路径配置
## - 运行时的路径有效性检查
##
## 使用场景：
## - HFSM状态机的状态转换配置
## - 状态之间的跳转关系定义
## - 复杂状态机的结构管理
## - 状态转换的可视化编辑
##
## 验证规则：
## - 目标状态必须是 [StateHfsm] 类型
## - 目标状态必须是当前状态的兄弟节点
## - 路径格式必须符合 "../状态名" 的规范
##
## 架构设计：
## - 继承自 [Resource] 基类
## - 使用 [annotation @tool] 支持编辑器功能
## - 基于 [annotation @export_node_path] 的路径配置
## - 自定义setter进行路径验证
##
## [br][b]编辑者:[/b] Sora
@tool
class_name TrainsitionRecord
extends Resource

## 过渡到的目标状态
## 
## 要求状态属于 [StateHfsm] 类型，且必须是兄弟节点。
## 路径格式必须为 "../状态名"，类型为 [NodePath]。
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
