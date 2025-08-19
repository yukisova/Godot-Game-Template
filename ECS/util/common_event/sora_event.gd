## 游戏事件工具类 - 提供常用的静态方法和事件处理
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
##
## 工具方法：
## - 字典数据修复和转换
## - 节点路径解析和处理
## - 数据结构的深度处理
##
## 架构设计：
## - 继承自 [Node] 基类
## - 提供静态方法 [method fixed_dictionary]
## - 支持 [NodePath] 到 [Node] 的自动转换
## - 基于递归的深度数据处理
##
## [br][b]编辑者:[/b] Sora
class_name SoraEvent
extends Node

## 修复字典中的NodePath值
## 
## 递归地将字典中的 [NodePath] 值转换为实际的节点引用。
## 支持嵌套字典和数组的深度处理。
## [param node]: 作为路径解析基准的节点
## [param data]: 包含 [NodePath] 的字典数据
## [br][br][b]返回:[/b] [Dictionary] 修复后的字典，所有 [NodePath] 被转换为对应的 [Node] 引用
static func fixed_dictionary(node: Node, data: Dictionary) -> Dictionary:
	var fixed_data = data.duplicate_deep()
	
	# 遍历所有键值对，处理不同类型的值
	for key in fixed_data:
		if fixed_data[key] is NodePath:
			# 将NodePath转换为实际的节点引用
			fixed_data[key] = node.get_node(fixed_data[key])
		elif fixed_data[key] is Dictionary:
			# 递归处理嵌套字典
			fixed_data[key] = fixed_dictionary(node, fixed_data[key])
		elif fixed_data[key] is Array:
			# 处理数组中的字典和NodePath
			for i in fixed_data[key].size():
				if fixed_data[key][i] is Dictionary:
					fixed_data[key][i] = fixed_dictionary(node, fixed_data[key][i])
				elif fixed_data[key][i] is NodePath:
					fixed_data[key][i] = node.get_node(fixed_data[key][i])
	return fixed_data


#region 相机特效相关
static var camera_tween: Tween
## 相机抖动
static func camera_shake(node: Node2D, effect_strength: float = 1.0, effect_time: float = 0.5):
	var camera = node.get_viewport().get_camera_2d()
	if camera_tween: camera_tween.kill()
	
	camera_tween = node.get_tree().create_tween()
	camera_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	for i in effect_strength:
		var offset_strength = Vector2(randf_range(-effect_strength, effect_strength), randf_range(-effect_strength, effect_strength))
		camera_tween.stop()
		camera_tween.tween_property(camera, "offset", offset_strength, effect_time/(effect_strength+3))
		camera_tween.play()
		await camera_tween.finished
		camera.offset = Vector2.ZERO
#endregion
