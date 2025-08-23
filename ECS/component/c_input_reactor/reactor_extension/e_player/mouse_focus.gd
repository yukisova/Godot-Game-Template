## 鼠标焦点扩展 - 指定节点跟随鼠标位置移动
## 让Node2D节点始终跟随鼠标光标位置，支持多节点同步跟随
## 用于准星、鼠标指针、瞄准器等需要跟随鼠标的游戏元素
## [br][b]编辑者:[/b] Sora
class_name MouseFocusExtension
extends ReactorExtension

## 鼠标焦点节点数组
## 所有节点都会跟随鼠标位置移动
@export var mouse_focus: Array[Node2D]

func _setup():
	pass

## 每帧更新所有焦点节点位置到鼠标位置
func _listen():
	# 获取视口宽度
	var viewport_width = get_viewport().size.x
	
	# 遍历所有焦点节点，将其位置设置为鼠标位置
	for focus_node in mouse_focus:
		if is_instance_valid(focus_node):
			# 获取当前鼠标位置
			var mouse_pos = focus_node.get_global_mouse_position()
			
			# 限制鼠标位置在右半边屏幕
			mouse_pos.x = max(viewport_width / 2, mouse_pos.x)
			
			# 更新节点位置
			focus_node.global_position = mouse_pos if get_viewport() else Vector2.ZERO
