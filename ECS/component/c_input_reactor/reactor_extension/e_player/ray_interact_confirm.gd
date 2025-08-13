## @editing: Sora [br]
## @describe: 射线交互确认扩展 - 处理基于射线的交互操作
## 
## 该扩展使用射线检测来确定交互目标，并在玩家按下交互键时
## 触发射线方向上目标实体的交互事件。射线会自动朝向鼠标方向。
## 
## 交互机制：
## - 射线自动朝向鼠标位置
## - 检测射线路径上的交互目标
## - 按下交互键时触发目标实体的射线交互事件
## - 支持远程交互和精确定位
## 
## 应用场景：
## - 远程物体交互
## - 精确目标选择
## - 射击游戏的目标确认
## - 工具使用确认
class_name RayInteractConfirmExtension
extends ReactorExtension

## 交互射线
## 用于检测交互目标的射线组件
@export var interact_ray: InteractRay

## 监听射线交互操作
## 更新射线朝向并处理交互确认
func _listen():
	# 验证输入动作是否存在（只在第一次执行时检查）
	if not InputMap.has_action("interact"):
		if not get_meta("interact_error_logged", false):
			push_error("射线交互扩展: 输入动作 'interact' 不存在，请检查配置系统")
			set_meta("interact_error_logged", true)
		return
	
	# 计算从射线起点到鼠标位置的方向向量
	var vector = interact_ray.global_position.direction_to(interact_ray.get_global_mouse_position())
	# 设置射线朝向鼠标方向
	interact_ray.rotation = vector.angle()
	
	# 检测交互键按下事件
	if Input.is_action_just_pressed("interact"):
		print("射线交互: 检测到交互键按下")
		# 如果射线检测到交互目标，触发其射线交互事件
		if interact_ray.interact_target:
			print("射线交互: 触发交互目标 -> ", interact_ray.interact_target.name)
			interact_ray.interact_target.entity_ray_interact.emit(c_input_reactor.component_owner)
		else:
			print("射线交互: 没有检测到交互目标")
