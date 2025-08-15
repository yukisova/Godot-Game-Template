## @editing: Sora
## @describe: 游戏事件工具类 - 提供常用的静态方法和事件处理
## 
## 该类封装了游戏中常用的事件处理方法，主要包括：
## - 对话系统的便捷调用
## - 通用事件触发器
## - 场景切换工具
## - 其他常用的静态工具方法
## 
## 设计目标：
## - 简化复杂系统的调用流程
## - 提供统一的事件处理接口
## - 减少代码重复和耦合
class_name SoraEvent
extends Node

## 修复字典中的NodePath值
## 将字典中的NodePath值转换为实际的节点引用
## @param node: 节点
## @param data: 字典
## @return: 修复后的字典
static func fixed_dictionary(node: Node, data: Dictionary) -> Dictionary:
	var fixed_data = data.duplicate_deep()
	
	# 遍历所有键值对，处理NodePath类型的值
	for key in fixed_data:
		if fixed_data[key] is NodePath:
			# 将NodePath转换为实际的节点引用
			fixed_data[key] = node.get_node(fixed_data[key])
		elif fixed_data[key] is Dictionary:
			fixed_data[key] = fixed_dictionary(node, fixed_data[key])
		elif fixed_data[key] is Array:
			for i in fixed_data[key].size():
				if fixed_data[key][i] is Dictionary:
					fixed_data[key][i] = fixed_dictionary(node, fixed_data[key][i])
				elif fixed_data[key][i] is NodePath:
					fixed_data[key][i] = node.get_node(fixed_data[key][i])
	return fixed_data

