## @editing: Sora [br]
## @describe: 鼠标焦点扩展 - 使指定节点跟随鼠标位置移动
## 
## 该扩展用于让特定的Node2D节点始终跟随鼠标光标的位置移动。
## 常用于准星、鼠标指针、瞄准器等需要跟随鼠标的游戏元素。
## 
## 应用场景：
## - 游戏准星显示
## - 鼠标光标替换
## - 瞄准器跟随
## - 鼠标交互指示器
## 
## 功能特性：
## - 多节点同步跟随
## - 实时位置更新
## - 简单高效的实现
class_name MouseFocusExtension
extends ReactorExtension

## 鼠标焦点节点数组
## 所有在此数组中的Node2D节点都会跟随鼠标位置移动
@export var mouse_focus: Array[Node2D]

## 监听鼠标位置更新
## 每帧更新所有焦点节点的位置到鼠标位置
func _listen():
	# 遍历所有焦点节点，将其位置设置为鼠标位置
	for focus_node in mouse_focus:
		if is_instance_valid(focus_node):
			focus_node.global_position = focus_node.get_global_mouse_position() if get_viewport() else Vector2.ZERO
