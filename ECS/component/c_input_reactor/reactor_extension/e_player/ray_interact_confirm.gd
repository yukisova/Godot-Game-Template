class_name RERayInteractConfirm
extends ReactorExtension
## 是否控制朝向瞄准鼠标方向
@export var toward_control_by_mouse: bool = false:
	set(v):
		toward_control_by_mouse = v
		
		if not Engine.is_editor_hint() and is_node_ready():
			var c_action_trigger: CActionTrigger= c_input_reactor.get_other_component(IComponent.ComponentName.C_ACTION_TRIGGER)
			var move_strategy = c_action_trigger.move_strategy
			if !move_strategy.is_empty():
				var move_strategy_vector = move_strategy[0] as MoveStrategyVector
				if move_strategy_vector:
					move_strategy_vector.toward_control_by_move = false if toward_control_by_mouse else true

## 交互射线组件
@export var interact_ray: InteractRay

## 状态组件，用于访问装备系统
@export var c_status: CStatusList
@export var movement_input: REMovementInput

func _late_initialize():
	if toward_control_by_mouse:
		var c_action_trigger: CActionTrigger= c_input_reactor.get_other_component(IComponent.ComponentName.C_ACTION_TRIGGER)
		var move_strategy = c_action_trigger.move_strategy
		if !move_strategy.is_empty():
			var move_strategy_vector = move_strategy[0] as MoveStrategyVector
			if move_strategy_vector:
				move_strategy_vector.toward_control_by_move = false

## 更新射线朝向并处理交互确认和攻击操作
func _listen():
	# 设置射线朝向鼠标方向
	var vector: Vector2
	
	if toward_control_by_mouse:
		var mouse_info = SoraEvent.fixed_camera_position(c_input_reactor.component_owner.main_control)
		if !mouse_info.is_empty():
			# 获取视口中的鼠标位置
			var mouse_pos = mouse_info["viewport_mouse_pos"]
			# 获取玩家在世界中的位置
			var player_pos = mouse_info["player_pos"]
			# 计算鼠标相对于相机的位置
			var camera_center = mouse_info["camera_center"]
			# 获取视口大小
			var viewport_size = mouse_info["viewport_size"]

			# 计算从玩家位置到鼠标位置的方向向量
			# 这里的关键是：鼠标位置是视口相对坐标，需要转换为世界坐标
			vector = ((mouse_pos - viewport_size/2.0) + (player_pos - camera_center)).normalized()
		else:
			vector = Vector2.RIGHT # 默认方向
		# 设置武器攻击节点的朝向
		var c_texture_controller: CTextureController = c_status.component_owner.list_base_components[IComponent.ComponentName.C_TEXTURE_CONTROLLER]
		if c_texture_controller and c_texture_controller.packed_sprite:
			c_texture_controller.packed_sprite.texture_toward = vector
	else:
		vector = movement_input.get_toward_vector()

	# 如果方向向量足够长，设置射线朝向
	if vector.length() > 0.1: # 避免零向量
		interact_ray.rotation = vector.angle()


	# 检测交互键按下事件
	if c_input_reactor.validate_control("interact", SoraConstant.InputType.JUST_PRESSED):
		print("射线交互: 检测到交互键按下")
		# 如果射线检测到交互目标，触发其射线交互事件
		if interact_ray.interact_target:
			print("射线交互: 触发交互目标 -> ", interact_ray.interact_target.name)
			interact_ray.interact_target.entity_ray_interact.emit(c_input_reactor.component_owner)
		else:
			print("射线交互: 没有检测到交互目标")
