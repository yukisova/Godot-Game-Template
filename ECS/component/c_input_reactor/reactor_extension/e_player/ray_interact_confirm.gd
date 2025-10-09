## 交互确认组件
## 用于处理玩家的交互输入，将原本在CInputReactor中的交互逻辑拆分出来，并另外出现InputReactor的组件
class_name REInteractConfirm
extends ReactorExtension

## 角色面对的方向的可交互实体（拟代替InteractRay）
var ray_entity: IEntity
## 角色所在区域的可交互实体（拟代替原本在CInteractReactor的交互逻辑）
var area_entry_interaction: Array[IInteraction] = []
## 角色所拥有的特殊BoxCollision指定的可交互实体
var box_special_interaction: Dictionary[BoxCollision , IInteraction] = {}

## 状态组件，用于访问装备系统
@export var c_status: CStatusList
@export var movement_input: REMovementInput
@export var movement_vector: MoveStrategyVector


func _enter_tree() -> void:
	extention_type = REType.INTERACT_CONFIRM

func _late_initialize():
	## 判断当前的角色是否是基于鼠标方向控制每一帧判断
	pass

## 更新射线朝向并处理交互确认和攻击操作
func _listen():
	# 设置射线朝向鼠标方向
	var ray_vector: Vector2

	match movement_input.toward_mode:
		movement_input.TowardMode.MOVE:
			ray_vector = movement_input.get_toward_vector()
		movement_input.TowardMode.MOUSE:
			ray_vector = movement_vector._get_current_direction()	

	update_ray_query(ray_vector)

	if c_input_reactor.validate_control("interact", SoraConstant.InputType.JUST_PRESSED):
		print("检测到交互键按下")
		## 射线交互优先，区域交互次之，特殊Box交互最后
		if ray_entity:
			print("触发射线交互目标 -> ", ray_entity.name)
			ray_entity.entity_ray_interact.emit(c_input_reactor.component_owner)
		elif not area_entry_interaction.is_empty():
			var interaction = area_entry_interaction[0]
			print("触发区域交互目标 -> ", interaction.binding_entity.name)
			interaction.interact_activated.emit(c_input_reactor.component_owner)
		elif not box_special_interaction.is_empty():
			pass

## 更新射线查询以检测交互对象
func update_ray_query(ray_vector: Vector2, length: float = 50.0):
	# 计算射线的起点和终点
	var start_position = c_input_reactor.component_owner.main_control.global_position
	var end_position = start_position + ray_vector.normalized() * length

	# 进行射线检测，忽略玩家自己
	var space_state = c_input_reactor.component_owner.get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(start_position, end_position)
	query.exclude = [c_input_reactor.component_owner.main_control]
	query.collide_with_areas = false
	query.collide_with_bodies = true

	query.collision_mask = Main.PhysicsLayer.Interactable

	var result = space_state.intersect_ray(query)

	# 处理射线检测结果
	if result:
		var collider = result.collider
		if collider and collider is Node:
			var collider_node = collider as Node
			if collider_node.is_in_group("interactable"):
				var interactable_entity = collider_node.get_parent() as IEntity
				if interactable_entity:
					ray_entity = interactable_entity
					return
	# 如果没有检测到有效的交互对象，清空当前射线交互对象
	ray_entity = null
