## 射线交互确认扩展 - 处理基于射线的交互和攻击操作
## 射线自动朝向鼠标方向，检测交互目标并触发交互事件
## 同时控制武器朝向和攻击动作，适用于远程交互和精确瞄准
## [br][b]编辑者:[/b] Sora
class_name RayInteractConfirmExtension
extends ReactorExtension

## 交互射线组件
@export var interact_ray: InteractRay

## 状态组件，用于访问装备系统
@export var c_status: CStatusList

func _setup():
	pass

## 更新射线朝向并处理交互确认和攻击操作
func _listen():
	# 计算从射线起点到鼠标位置的方向向量

	# 设置射线朝向鼠标方向
	var vector = c_input_reactor.input_vector_dict.get("toward", Vector2.ZERO)
	interact_ray.rotation = vector.angle()


	# 设置武器攻击节点的朝向
	var c_texture_controller: CTextureController = c_status.component_owner.list_base_components[IComponent.ComponentName.C_TEXTURE_CONTROLLER]
	if c_texture_controller and c_texture_controller.packed_sprite:
		c_texture_controller.packed_sprite.texture_toward = vector

	var equipment_extension: EquipmentExtension = c_status.status_extension[StatusExtension.ExtensionType.EQUIPMENT]

	# 检测交互键按下事件
	if c_input_reactor.validate_control("interact", SoraConstant.InputType.JUST_PRESSED):
		print("射线交互: 检测到交互键按下")
		# 如果射线检测到交互目标，触发其射线交互事件
		if interact_ray.interact_target:
			print("射线交互: 触发交互目标 -> ", interact_ray.interact_target.name)
			interact_ray.interact_target.entity_ray_interact.emit(c_input_reactor.component_owner)
		else:
			print("射线交互: 没有检测到交互目标")
	
	if c_input_reactor.validate_control("primary_action", SoraConstant.InputType.JUST_PRESSED):
		if equipment_extension.current_attack_node:
			equipment_extension.current_attack_node._trigger_effect()
