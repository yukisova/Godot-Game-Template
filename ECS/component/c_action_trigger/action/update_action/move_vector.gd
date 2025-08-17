## 向量移动策略 - 基于2D向量的实体移动实现
##
## 该策略实现了基于向量的移动系统，支持两种控制模式：
## 1. 输入控制：通过玩家输入组件获取移动向量（用于玩家角色）
## 2. AI控制：通过代码直接设置移动向量（用于NPC和敌人）
##
## 移动特性：
## - 支持平滑的速度过渡
## - 自动朝向计算
## - [CharacterBody2D] 集成
## - 可配置的移动速度
## - 智能移动状态识别
## - 基于current_action_state的统一状态管理
##
## 适用场景：
## - 玩家角色控制
## - NPC移动
## - 敌人AI移动
## - 简单的物体推动
##
## 架构设计：
## - 继承自 [IUpdateAction] 基类
## - 与 [CInputReactor] 组件集成
## - 基于 [Vector2] 的移动控制
## - 支持自动和手动两种控制模式
##
## [br][b]编辑者:[/b] Sora
class_name MoveVector
extends IUpdateAction

## 输入响应组件引用
## 
## 如果设置，将从该组件获取移动输入；如果为null，则需要手动设置move_vector。
## 类型为 [CInputReactor]。
@export var c_input: CInputReactor = null

## 移动向量
## 
## 控制实体的移动方向和强度，自动处理输入控制和AI控制两种模式。
## 类型为 [Vector2]。
var move_vector: Vector2:
	get:
		if binding_entity.main_control is CharacterBody2D:
			if c_input:
				# 输入控制模式：从输入组件获取移动向量
				var input_vector = c_input.input_vector_dict.move
				toward_direction = input_vector.normalized()
				return input_vector
			else:
				# AI控制模式：使用手动设置的移动向量
				toward_direction = move_vector.normalized()
				return move_vector
		else:
			push_error("向量移动策略: 目标实体不支持移动，请使用其他移动方案")
			return Vector2.ZERO
	set(value):
		move_vector = value

## 移动速度
## 
## 控制实体移动的速度倍数。
@export var move_speed: float

## 朝向方向
## 
## 实体当前面对的方向，由移动向量自动计算。类型为 [Vector2]。
var toward_direction: Vector2

## 移动状态检测阈值
## 
## 用于判断实体是否在移动的速度阈值，避免微小抖动被误判为移动。
@export var movement_threshold: float = 5.0

## 策略初始化
## 验证绑定实体的适用性，初始化移动状态和相关参数
func _initialize():
	action_states = ["idle", "movement"]
	current_action_state = action_states[0]

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

## 移动逻辑更新
## 
## 根据移动向量和速度更新实体的velocity，并应用平滑过渡效果。
## 同时检测和更新移动状态。
## [param _delta]: 帧时间间隔
func _update(_delta: float):
	var body = binding_entity.main_control
	
	# 只有具有输入组件的实体才会自动移动（玩家控制）
	# AI控制的实体需要外部代码设置move_vector
	if c_input:
		if not move_vector.is_zero_approx():
			# 应用移动：使用lerp实现平滑的速度过渡
			body.velocity = body.velocity.lerp(move_vector * _delta * 10 * move_speed, _delta * 10)
		else:
			# 停止移动：平滑减速到零
			body.velocity = body.velocity.lerp(Vector2.ZERO, _delta * 10)
		
		# 应用物理移动
		body.move_and_slide()
	
	# 检测移动状态变化
	_detect_state()

## 检测移动状态变化
## 
## 根据当前速度和阈值判断移动状态，并在状态变化时更新行为状态。
func _detect_state():
	var current_speed = get_current_speed()
	var should_be_moving = current_speed > movement_threshold
	
	# 确定应该处于的状态
	var target_state = action_states[1] if should_be_moving else action_states[0]  # "movement" or "idle"
	
	# 只有状态真正变化时才更新
	if current_action_state != target_state:
		_update_movement_state(target_state)

## 重置移动状态
## 
## 将移动状态重置为静止状态，通常在实体被重新初始化时调用。
func _reset():
	toward_direction = Vector2.ZERO
	current_action_state = action_states[0]  # "idle"
	# 重置action状态为idle
	if c_action:
		c_action.current_action_list[self as IAction] = action_states[0]

## 保存策略状态
## 
## 将当前移动策略的状态序列化为字典格式。
## [br][br][b]返回:[/b] [Dictionary] 包含策略类型、朝向、移动向量、速度和当前状态的字典
func _save_as() -> Dictionary:
	return {
		"type": MoveStrategyType.VectorMove,
		"toward_direction": toward_direction,
		"move_vector": Vector2.ZERO,  # 移动向量重置，避免存档时保持移动状态
		"move_speed": move_speed,
		"current_action_state": action_states[0]  # 存档时重置为idle状态
	}
