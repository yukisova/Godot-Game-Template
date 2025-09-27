## 向量移动策略 - 基于2D向量的实体移动实现
## 该策略实现了基于向量的移动系统，支持输入控制和AI控制两种模式
## 输入控制：通过玩家输入组件获取移动向量，AI控制：通过代码直接设置移动向量
## 移动特性：支持平滑的速度过渡、自动朝向计算、智能移动状态识别
## 适用场景：玩家角色控制、NPC移动、敌人AI移动、简单的物体推动
## 架构设计：继承自 [IUpdateAction] 基类，与 [CInputReactor] 组件集成
## [br][b]编辑者:[/b] Sora
class_name MoveStrategyVector
extends MoveStrategy

## 输入响应组件引用
## 如果设置，将从该组件获取移动输入；如果为null，则需要手动设置move_vector
@export var movement_input: REMovementInput = null

## 是否基于移动方向控制角色朝向(由外部控制)
var toward_control_by_move: bool = true:
	set(v):
		toward_control_by_move = v

## 由外界设置的特殊移动方案，在某些情况下
var fixed_move_callable: Callable
var fixed_move_callable_setted: bool = false

## 移动向量
## 控制实体的移动方向和强度，自动处理输入控制和AI控制两种模式

func _get_move_vector() -> Vector2:
	if c_action.component_body is CharacterBody2D:
		if movement_input:
			# 输入控制模式：从输入组件获取移动向量
			var input_vector = movement_input.input_vector_dict.move as Vector2
			if toward_control_by_move:
				_set_target_direction(self, input_vector.normalized())
			return input_vector
		else:
			return move_vector
	else:
		push_error("向量移动策略: 目标实体不支持移动，请使用其他移动方案")
		return Vector2.ZERO

func _set_move_vector(vector: Vector2):
	move_vector = vector
	if !move_vector.is_zero_approx():
		if toward_control_by_move:
			_set_target_direction(self, move_vector.normalized())

## 移动速度
## 控制实体移动的速度倍数
@export var move_speed: float

## 朝向方向
## 实体当前面对的方向，由移动向量自动计算
var toward_direction_current: Vector2:
	set(v):
		toward_direction_current = v

		var c_collision_box: CCollisionBox = c_action.get_other_component(IComponent.ComponentName.C_COLLISION_BOX)
		## 将朝向方向应用到所有启用朝向旋转的碰撞体
		if c_collision_box:
			for rotate_enable_box in c_collision_box.box_collision.values().filter(func(box_collision: BoxCollision): return box_collision.enable_rotate_by_award):
				rotate_enable_box.rotation = v.angle()
			for rotate_enable_ray in c_collision_box.box_rays.values().filter(func(box_ray: BoxRay): return box_ray.enable_rotate_by_award):
				rotate_enable_ray.rotation = v.angle()
			for rotate_enable_marker in c_collision_box.box_markers.values().filter(func(box_marker: BoxMarker): return box_marker.enable_rotate_by_award):
				rotate_enable_marker.rotation = v.angle()


		var c_texture_controller: CTextureController = c_action.get_other_component(IComponent.ComponentName.C_TEXTURE_CONTROLLER)
		if c_texture_controller:
			c_texture_controller.packed_sprite.texture_toward = v

## 目标朝向方向，由toward_direction_current进行平滑过渡，如果toward_control_by_move为false，则由外部控制
var toward_direction_target: Vector2
		
func _set_target_direction(source: Node2D, vector: Vector2):
	if source == self and toward_control_by_move:
		toward_direction_target = vector
	
	elif source != self and !toward_control_by_move:
		toward_direction_target = vector

func _get_current_direction() -> Vector2:
	return toward_direction_current

## 移动状态检测阈值
## 用于判断实体是否在移动的速度阈值
@export var movement_threshold: float = 5.0

## 验证绑定实体的适用性，初始化移动状态和相关参数
func _initialize():
	action_states = ["idle", "movement"]
	current_action_state = action_states[0]

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

## 根据移动向量和速度更新实体的velocity，并应用平滑过渡效果
## [param _delta]: 帧时间间隔
func _update(_delta: float):
	var body = c_action.component_body
	
	# 只有具有输入组件的实体才会自动移动（玩家控制）
	# AI控制的实体需要外部代码设置move_vector
	if movement_input:
		if fixed_move_callable and fixed_move_callable_setted:
			fixed_move_callable.call(_delta)
		else:
			if not _get_move_vector().is_zero_approx():
				# 应用移动：使用lerp实现平滑的速度过渡
				body.velocity = body.velocity.lerp(_get_move_vector() * _delta * 10 * move_speed, _delta * 10)
			else:
				# 停止移动：平滑减速到零
				body.velocity = body.velocity.lerp(Vector2.ZERO, _delta * 10)
			# 应用物理移动
			body.move_and_slide()
	
	## 2. 更新朝向方向
	if !toward_direction_target.is_equal_approx(toward_direction_current):
		var rotate_lerp_angle = lerp_angle(toward_direction_current.angle(), toward_direction_target.angle(), _delta * 10)
		toward_direction_current = Vector2.RIGHT.rotated(rotate_lerp_angle)

	# 检测移动状态变化
	_detect_state()

## 根据当前速度和阈值判断移动状态，并在状态变化时更新行为状态
func _detect_state():
	var current_speed = get_current_speed()
	var should_be_moving = current_speed > movement_threshold
	
	# 确定应该处于的状态
	var target_state = action_states[1] if should_be_moving else action_states[0]  # "movement" or "idle"
	
	# 只有状态真正变化时才更新
	if current_action_state != target_state:
		_update_movement_state(target_state)

## 将移动状态重置为静止状态，通常在实体被重新初始化时调用
func _reset():
	toward_direction_target = Vector2.ZERO
	current_action_state = action_states[0]  # "idle"
	# 重置action状态为idle
	if c_action:
		c_action.current_action_list[self as IAction] = action_states[0]

## 将当前移动策略的状态序列化为字典格式
## [br][br][b]返回:[/b] [Dictionary] 包含策略类型、朝向、移动向量、速度和当前状态的字典
func _save_as() -> Dictionary:
	return {
		"toward_direction_target": toward_direction_target,
		"move_vector": Vector2.ZERO,  # 移动向量重置，避免存档时保持移动状态
		"move_speed": move_speed,
		"current_action_state": action_states[0]  # 存档时重置为idle状态
	}

func _validate_property(property: Dictionary) -> void:
	if movement_input:
		if property.name == "move_speed":
			property.usage = PROPERTY_USAGE_NO_EDITOR
