## 射线交互确认扩展 - 处理基于射线的交互和攻击操作
## 射线自动朝向鼠标方向，检测交互目标并触发交互事件
## 同时控制武器朝向和攻击动作，适用于远程交互和精确瞄准
## [br][b]编辑者:[/b] Sora
class_name RayInteractConfirmExtension
extends ReactorExtension
@export var is_control_by_mouse: bool = false

## 交互射线组件
@export var interact_ray: InteractRay

## 状态组件，用于访问装备系统
@export var c_status: CStatusList

func _setup():
	pass

## 更新射线朝向并处理交互确认和攻击操作
func _listen():
	# 设置射线朝向鼠标方向
	var vector: Vector2
	
	if is_control_by_mouse:
		# 获取玩家所在的视口容器
		var camera_viewport = SViewportManager.get_viewport_container(c_input_reactor.component_owner.main_control)
		if camera_viewport:
			# 获取视口中的鼠标位置
			var mouse_pos = camera_viewport.get_viewport_mouse_position()
			
			# 获取玩家在世界中的位置
			var player_pos = c_input_reactor.component_owner.main_control.global_position
			
			# 计算鼠标相对于相机的位置
			var camera_center = camera_viewport.camera.get_screen_center_position()
			
			# 计算从玩家位置到鼠标位置的方向向量
			# 这里的关键是：鼠标位置是视口相对坐标，需要转换为世界坐标
			vector = ((mouse_pos - camera_viewport.viewport.size/2.0) + (player_pos - camera_center)).normalized()
		else:
			vector = Vector2.RIGHT # 默认方向
	else:
		vector = c_input_reactor.input_vector_dict.get("toward", Vector2.ZERO)

	# 如果方向向量足够长，设置射线朝向
	if vector.length() > 0.1: # 避免零向量
		interact_ray.rotation = vector.angle()


	# 设置武器攻击节点的朝向
	var c_texture_controller: CTextureController = c_status.component_owner.list_base_components[IComponent.ComponentName.C_TEXTURE_CONTROLLER]
	if c_texture_controller and c_texture_controller.packed_sprite:
		c_texture_controller.packed_sprite.texture_toward = vector

	# 检测交互键按下事件
	if c_input_reactor.validate_control("interact", SoraConstant.InputType.JUST_PRESSED):
		print("射线交互: 检测到交互键按下")
		# 如果射线检测到交互目标，触发其射线交互事件
		if interact_ray.interact_target:
			print("射线交互: 触发交互目标 -> ", interact_ray.interact_target.name)
			interact_ray.interact_target.entity_ray_interact.emit(c_input_reactor.component_owner)
		else:
			print("射线交互: 没有检测到交互目标")
