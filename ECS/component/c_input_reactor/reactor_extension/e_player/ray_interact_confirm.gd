## 射线交互确认扩展 - 处理基于射线的交互操作
## 
## 该扩展使用射线检测来确定交互目标，并在玩家按下交互键时
## 触发射线方向上目标实体的交互事件。射线会自动朝向鼠标方向。
## 
## 核心功能：
## - 动态的射线方向控制
## - 精确的交互目标检测
## - 武器攻击节点的联动
## - 完整的错误处理机制
## 
## 交互机制：
## - [b]射线朝向[/b]：射线自动朝向鼠标位置
## - [b]目标检测[/b]：检测射线路径上的交互目标
## - [b]交互触发[/b]：按下交互键时触发目标实体的射线交互事件
## - [b]攻击联动[/b]：同步控制武器攻击节点的朝向
## 
## 输入处理：
## - 实时计算鼠标方向向量
## - 同步更新射线和武器朝向
## - 交互键按下的事件处理
## - 主要攻击动作的处理
## 
## 应用场景：
## - 远程物体交互：远距离的精确交互
## - 精确目标选择：基于射线的目标确认
## - 射击游戏：目标瞄准和攻击确认
## - 工具使用确认：工具对特定物体的操作
## - 建造系统：建筑物的精确放置
##
## 架构设计：
## - 继承自 [ReactorExtension] 基类
## - 集成 [InteractRay] 射线检测系统
## - 与 [CStatusList] 和 [EquipmentExtension] 装备系统集成
## - 基于输入映射的动作处理
##
## [br][b]编辑者:[/b] Sora
class_name RayInteractConfirmExtension
extends ReactorExtension

## 交互射线
## 
## 用于检测交互目标的射线组件，类型为 [InteractRay]。
@export var interact_ray: InteractRay

## 状态组件
## 
## 角色的状态组件，用于访问装备系统，类型为 [CStatusList]。
@export var c_status: CStatusList

## 监听射线交互操作（重写方法）
## 
## 更新射线朝向并处理交互确认和攻击操作。
func _listen():
	# 验证输入动作是否存在（只在第一次执行时检查）
	if not InputMap.has_action("interact"):
		if not get_meta("interact_error_logged", false):
			push_error("射线交互扩展: 输入动作 'interact' 不存在，请检查配置系统")
			set_meta("interact_error_logged", true)
		return
	
	# 计算从射线起点到鼠标位置的方向向量
	var vector = interact_ray.global_position.direction_to(interact_ray.get_global_mouse_position()).normalized() if get_viewport() else Vector2.ZERO
	# 设置射线朝向鼠标方向
	interact_ray.rotation = vector.angle()

	# 设置武器攻击节点的朝向
	var c_texture_controller: CTextureController = c_status.component_owner.list_base_components[IComponent.ComponentName.C_TEXTURE_CONTROLLER]
	if c_texture_controller and c_texture_controller.packed_sprite:
		c_texture_controller.packed_sprite.texture_toward = vector

	var equipment_extension: EquipmentExtension = c_status.status_extension[StatusExtension.ExtensionType.EQUIPMENT]

	# 检测交互键按下事件
	if Input.is_action_just_pressed("interact"):
		print("射线交互: 检测到交互键按下")
		# 如果射线检测到交互目标，触发其射线交互事件
		if interact_ray.interact_target:
			print("射线交互: 触发交互目标 -> ", interact_ray.interact_target.name)
			interact_ray.interact_target.entity_ray_interact.emit(c_input_reactor.component_owner)
		else:
			print("射线交互: 没有检测到交互目标")
	
	if Input.is_action_just_pressed("primary_action"):
		if equipment_extension.current_attack_node:
			equipment_extension.current_attack_node._trigger_effect()
