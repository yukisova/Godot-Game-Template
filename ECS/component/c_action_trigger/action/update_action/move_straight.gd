## 直线飞行策略 - 实现高速直线移动的移动策略
##
## 该策略专为需要高速直线移动的实体设计，如子弹、飞行道具、魔法效果等。
## 具有自动销毁机制，当到达目标位置或超时时会自动删除实体。
##
## 移动特性：
## - 高速直线移动
## - 基于目标位置的自动导航
## - 超时自动销毁机制
## - 到达目标自动销毁
## - 智能移动状态识别
## - 基于current_action_state的统一状态管理
##
## 适用场景：
## - 子弹飞行
## - 投掷物移动
## - 魔法弹道
## - 临时特效对象
##
## 架构设计：
## - 继承自 [IUpdateAction] 基类
## - 与 [TempEntity] 的生命周期集成
## - 基于 [CharacterBody2D] 的物理移动
## - 通过黑板系统获取初始参数
##
## [br][b]编辑者:[/b] Sora
class_name MoveStrategyStraight
extends IUpdateAction

## 移动方向向量
## 
## 从黑板获取的初始移动方向，保持不变直到销毁。类型为 [Vector2]。
var direction: Vector2

## 存活时间计数器
## 
## 用于跟踪实体存活时间，超时后自动销毁。
var _time: float

## 移动状态检测阈值
## 
## 用于判断实体是否在移动的速度阈值，避免微小抖动被误判为移动。
@export var movement_threshold: float = 50.0  # 直线移动速度较高，阈值相应调高

## 生命周期最大时间
## 
## 实体的最大存活时间，超时后自动销毁。
@export var max_lifetime: float = 2.0

## 策略初始化
## 验证实体类型，设置自动销毁定时器，并从黑板获取移动参数
func _initialize():
	action_states = ["idle", "movement", "destroying"]
	current_action_state = action_states[0]  # 初始化为idle状态

	# 验证实体类型兼容性
	direction = blackboard.get_value("start_direction", Vector2.RIGHT)
	if binding_entity.main_control is not CharacterBody2D:
		push_error("直线飞行策略: 只适用于CharacterBody2D类型的实体")
		return
	if binding_entity is not TempEntity:
		push_error("直线飞行策略: 实体不是TempEntity类型")
		return
	
	# 从黑板获取初始移动方向和参数
	max_lifetime = blackboard.get_value("max_lifetime", 2.0)
	
	# 直线移动开始后立即进入移动状态
	_update_movement_state(action_states[1])  # "movement"

## 移动逻辑更新
## 
## 执行高速直线移动，检测状态变化，检查是否到达生命周期结束。
## [param _delta]: 帧时间间隔
func _update(_delta: float):
	# 应用高速直线移动
	binding_entity.main_control.velocity = direction * 5000 * _delta
	_time += _delta
	
	# 检测移动状态变化
	_detect_state()
	
	# 检查生命周期
	if _time > max_lifetime:
		_update_movement_state(action_states[2])  # "destroying"
		binding_entity.main_control.velocity = Vector2.ZERO
		(binding_entity as TempEntity).despawn()
		return
	
	# 应用物理移动
	binding_entity.main_control.move_and_slide()

## 更新移动状态
## 
## 根据移动状态变化更新行为状态列表和current_action_state，供状态机和纹理控制器使用。
## 使用self as IAction作为键名，确保类型安全和行为实例的唯一标识。
func _update_movement_state(new_state: StringName):
	if current_action_state != new_state:
		current_action_state = new_state
		c_action.current_action_list[self as IAction] = new_state

## 获取当前移动状态
## 
## 提供外部接口查询当前移动状态。
## [br][br][b]返回:[/b] [bool] true表示正在移动，false表示静止
func get_movement_status() -> bool:
	return current_action_state == action_states[1]  # "movement"

## 获取当前移动速度大小
## 
## 返回实体当前的实际移动速度大小（不包含方向）。
## [br][br][b]返回:[/b] [float] 当前速度的大小
func get_current_speed() -> float:
	if binding_entity and binding_entity.main_control is CharacterBody2D:
		return binding_entity.main_control.velocity.length()
	return 0.0

## 检查是否即将销毁
## 
## 检查实体是否接近生命周期结束。
## [br][br][b]返回:[/b] [bool] true表示即将销毁
func is_near_destruction() -> bool:
	return _time > (max_lifetime * 0.9)  # 90%生命周期后认为即将销毁

## 检测移动状态变化
## 
## 根据当前速度和阈值判断移动状态，并在状态变化时更新行为状态。
func _detect_state():
	var current_speed = get_current_speed()
	var should_be_moving = current_speed > movement_threshold
	
	# 直线移动的特殊逻辑：一旦开始就持续移动，直到销毁
	var target_state: StringName
	if _time > max_lifetime:
		target_state = action_states[2]  # "destroying"
	elif should_be_moving or _time > 0.1:  # 启动后0.1秒内认为应该移动
		target_state = action_states[1]  # "movement"
	else:
		target_state = action_states[0]  # "idle"
	
	# 只有状态真正变化时才更新
	if current_action_state != target_state:
		_update_movement_state(target_state)

## 重置移动状态
## 
## 将移动状态重置为初始状态，通常在实体被重新初始化时调用。
func _reset():
	direction = blackboard.get_value("start_direction", Vector2.RIGHT)
	max_lifetime = blackboard.get_value("max_lifetime", 2.0)
	_time = 0
	current_action_state = action_states[0]  # "idle"
	# 重置action状态为idle
	if c_action:
		c_action.current_action_list[self as IAction] = action_states[0]

## 保存策略状态
## 
## 直线飞行策略通常为临时对象，不需要存档。
## [br][br][b]返回:[/b] [Dictionary] 包含基本状态信息的字典（临时对象通常不保存）
func _save_as() -> Dictionary:
	# 直线飞行策略通常用于临时对象（如子弹），不需要存档
	# 但保留状态信息以便调试
	return {
		"direction": direction,
		"time": _time,
		"max_lifetime": max_lifetime,
		"current_action_state": action_states[0]  # 存档时重置为idle状态
	}
