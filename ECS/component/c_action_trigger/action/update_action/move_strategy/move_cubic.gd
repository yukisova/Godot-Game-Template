class_name MoveStrategyCurve
extends MoveStrategy

## 移动方向向量
## 从黑板获取的初始移动方向，保持不变直到销毁
var direction: Vector2

## 移动范围
## 移动范围，用于计算子弹在特定时间点的高度，并在到达目标位置时销毁（相当于子弹掉在地上）
var target_range: float

## 当前的已经发射的距离
var current_range: float = 0.0

var path: Path2D

## 距离阈值，用于判断实体是否到达目标位置
@export var range_threshold: float = 10.0

func _ready() -> void:
	for i in get_children():
		if i is Path2D:
			path = i

## 验证实体类型，在落地的时候进行销毁
func _initialize():
	action_states = ["idle", "movement", "destroying"]
	current_action_state = action_states[0]  # 初始化为idle状态

	# 验证实体类型兼容性
	direction = c_action.get_value("start_direction", Vector2.RIGHT)
	target_range = c_action.get_value("target_range", 200.0)
	
	var c_texture_controller = c_action.get_other_component(IComponent.ComponentName.C_TEXTURE_CONTROLLER)
	var new_height = path.curve.sample(0, 0).y
	c_texture_controller.current_height = new_height
	
	## 初始位置为实体位置
	current_range = 0.0

	if c_action.component_body is not CharacterBody2D:
		push_error("直线飞行策略: 只适用于CharacterBody2D类型的实体")
		return
	if c_action.component_owner is not TempEntity:
		push_error("直线飞行策略: 实体不是TempEntity类型")
		return
	
	# 直线移动开始后立即进入移动状态
	_update_movement_state(action_states[1])  # "movement"

## 执行高速直线移动，检测状态变化，检查是否到达生命周期结束
## [param _delta]: 帧时间间隔
func _update(_delta: float):
	# 应用高速直线移动
	c_action.component_body.velocity = direction * 50000 * _delta

	current_range += 50000 * _delta * _delta
	
	# 检测移动状态变化
	_detect_state()
	
	var c_texture_controller = c_action.get_other_component(IComponent.ComponentName.C_TEXTURE_CONTROLLER)
	
	## 更新当前的高度以及当前的
	if c_texture_controller:
		var new_height = path.curve.sample(0, current_range/target_range).y
		c_texture_controller.current_height = new_height

	# 检查生命周期
	if current_range > target_range - range_threshold:
		_update_movement_state(action_states[2])  # "destroying"
		(c_action.component_owner as TempEntity)._despawn()
		return
	
	# 应用物理移动
	c_action.component_body.move_and_slide()

## 根据移动状态变化更新行为状态列表和current_action_state
## [param new_state]: 新的状态值
func _update_movement_state(new_state: StringName):
	if current_action_state != new_state:
		current_action_state = new_state
		c_action.current_action_list[self as IAction] = new_state

## 提供外部接口查询当前移动状态
## [br][br][b]返回:[/b] [bool] true表示正在移动，false表示静止
func get_movement_status() -> bool:
	return current_action_state == action_states[1]  # "movement"

## 返回实体当前的实际移动速度大小（不包含方向）
## [br][br][b]返回:[/b] [float] 当前速度的大小
func get_current_speed() -> float:
	if c_action.component_body is CharacterBody2D:
		return c_action.component_body.velocity.length()
	return 0.0
	
func _detect_state():
	var should_be_moving = current_range > target_range - range_threshold
	
	var target_state: StringName
	if current_range > target_range:
		target_state = action_states[2]  # "destroying"
	elif should_be_moving:  # 启动后认为应该移动
		target_state = action_states[1]  # "movement"
	else:
		target_state = action_states[0]  # "idle"
	
	# 只有状态真正变化时才更新
	if current_action_state != target_state:
		_update_movement_state(target_state)

## 将移动状态重置为初始状态，通常在实体被重新初始化时调用
func _reset():
		# 验证实体类型兼容性
	direction = c_action.get_value("start_direction", Vector2.RIGHT)
	target_range = c_action.get_value("target_range", 200.0)
	current_range = 0.0

	current_action_state = action_states[0]  # "idle"
	# 重置action状态为idle
	if c_action:
		c_action.current_action_list[self as IAction] = action_states[0]

## 直线飞行策略通常为临时对象，不需要存档
## [br][br][b]返回:[/b] [Dictionary] 包含基本状态信息的字典
func _save_as() -> Dictionary:
	# 直线飞行策略通常用于临时对象（如子弹），不需要存档
	# 但保留状态信息以便调试
	return {
		"direction": direction,
		"current_action_state": action_states[0]  # 存档时重置为idle状态
	}
