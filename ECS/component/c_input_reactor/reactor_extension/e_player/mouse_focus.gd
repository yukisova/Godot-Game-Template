## 鼠标焦点扩展 - 指定节点跟随鼠标位置移动
## 让Node2D节点始终跟随鼠标光标位置，支持多节点同步跟随
## 用于准星、鼠标指针、瞄准器等需要跟随鼠标的游戏元素
## [br][b]编辑者:[/b] Sora
class_name MouseFocusExtension
extends ReactorExtension

## 鼠标焦点节点数组
## 所有节点都会跟随鼠标位置移动
@export var mouse_focus: Array[Node2D]
## 是否限制鼠标在右半屏幕
@export var restrict_to_right_half: bool = false

func _setup():
	pass

## 每帧更新所有焦点节点位置到鼠标位置
func _listen():
	# 遍历所有焦点节点，将其位置设置为鼠标位置
	for focus_node in mouse_focus:
		if is_instance_valid(focus_node):
			# 获取玩家所在的视口容器
			var camera_viewport = SCameraController.get_viewport_container(c_input_reactor.component_owner.main_control)
			
			if camera_viewport:
				# 获取视口中的鼠标位置
				var mouse_pos = camera_viewport.get_viewport_mouse_position()
				
				# 获取玩家在世界中的位置
				var player_pos = c_input_reactor.component_owner.global_position
				
				# 计算鼠标相对于相机的位置
				var camera_center = camera_viewport.camera.get_screen_center_position()
				
				# 计算从鼠标位置在世界坐标系中的位置
				var world_mouse_pos = (mouse_pos - camera_viewport.viewport.size/2) + camera_center
				
				# 如果需要限制在右半屏
				if restrict_to_right_half:
					var player_x = player_pos.x
					world_mouse_pos.x = max(player_x, world_mouse_pos.x)
				
				# 设置节点位置为世界坐标中的鼠标位置
				focus_node.global_position = world_mouse_pos
			else:
				# 备用方案：直接使用全局鼠标位置
				focus_node.global_position = focus_node.get_global_mouse_position()