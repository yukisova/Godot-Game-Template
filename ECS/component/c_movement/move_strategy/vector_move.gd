## @editing: Sora [br]
## @describe: 向量移动策略 - 基于2D向量的实体移动实现
## 
## 该策略实现了基于向量的移动系统，支持两种控制模式：
## 1. 输入控制：通过玩家输入组件获取移动向量（用于玩家角色）
## 2. AI控制：通过代码直接设置移动向量（用于NPC和敌人）
## 
## 移动特性：
## - 支持平滑的速度过渡
## - 自动朝向计算
## - CharacterBody2D集成
## - 可配置的移动速度
## 
## 适用场景：
## - 玩家角色控制
## - NPC移动
## - 敌人AI移动
## - 简单的物体推动
class_name MoveStrategyVector
extends MoveStrategy

## 输入响应组件引用
## 如果设置，将从该组件获取移动输入；如果为null，则需要手动设置move_vector
@export var c_input: C_InputReactor = null

## 移动向量
## 控制实体的移动方向和强度，自动处理输入控制和AI控制两种模式
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
## 控制实体移动的速度倍数
@export var move_speed: float

## 朝向方向
## 实体当前面对的方向，由移动向量自动计算
var toward_direction: Vector2

## 策略检查和初始化
## 验证绑定实体的适用性，当前向量移动策略无需特殊初始化
func _check_and_init():
	# 向量移动策略适用于所有CharacterBody2D，无需额外初始化
	pass

## 移动逻辑更新
## 根据移动向量和速度更新实体的velocity，并应用平滑过渡效果
## @param _delta: 帧时间间隔
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

## 保存策略状态
## 将当前移动策略的状态序列化为字典格式
## @return: 包含策略类型、朝向、移动向量和速度的字典
func _save_as() -> Dictionary:
	return {
		"type": MoveStrategyType.VectorMove,
		"toward_direction": toward_direction,
		"move_vector": Vector2.ZERO,  # 移动向量重置，避免存档时保持移动状态
		"move_speed": move_speed
	}
