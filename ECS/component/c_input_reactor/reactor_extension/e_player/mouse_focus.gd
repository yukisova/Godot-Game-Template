## 鼠标焦点扩展 - 指定节点跟随鼠标位置移动
## 让Node2D节点始终跟随鼠标光标位置，支持多节点同步跟随
## 用于准星、鼠标指针、瞄准器等需要跟随鼠标的游戏元素
## [br][b]编辑者:[/b] Sora
class_name MouseFocusExtension
extends ReactorExtension

## 鼠标焦点节点数组
## 所有节点都会跟随鼠标位置移动
@export var mouse_focus: Array[Node2D]

## 每帧更新所有焦点节点位置到鼠标位置
func _listen():
	# 遍历所有焦点节点，将其位置设置为鼠标位置
	for focus_node in mouse_focus:
		if is_instance_valid(focus_node):
			focus_node.global_position = focus_node.get_global_mouse_position() if get_viewport() else Vector2.ZERO
