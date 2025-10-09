## 玩家HFSM根状态机 - 管理玩家的状态转换和特殊输入
## 架构设计：
## - 继承自 [StateMachine] 基类
## - 使用 [annotation @tool] 支持编辑器功能
## - 集成 [IAction] 行动系统
## - 基于分组的导出变量管理
##
## [br][b]编辑者:[/b] Sora 
@tool
extends StateMachine

## 关联的ActionInput组件，用于处理玩家的输入操作，类型为 [REActionInput]。
@export var action_input: REActionInput
@export var c_texture_controller: CTextureController
@export var c_state_machine: CStateMachine

@export var vector_move: MoveStrategyVector
@export var collision_shape: CollisionShape2D
@export var movement_input: REMovementInput
var current_delta: float

## 状态输入tag与pda状态的映射关系
@export var state_tag_map: Dictionary[String, StateTemp]

## 按下奔跑1+正常状态 = 奔跑状态
## 贴近墙 = 贴墙状态
func _blur_update(_delta: float) -> void:
	## 状态机
	var export = 检测外部传入()
	if export != "":
		state_temp_updated.emit(state_tag_map[export])
	elif action_input.check_input_state("secondary_action"):
		state_temp_updated.emit(state_tag_map["secondary_action"])
	elif 检测贴墙状态(_delta):
		state_temp_updated.emit(state_tag_map["state_4"])
	elif action_input.check_input_state("state_0"):
		state_temp_updated.emit(state_tag_map["state_0"])
	# elif action_input.check_input_state("state_1"):
	# 	state_temp_updated.emit(state_tag_map["state_1"])
	# elif action_input.check_input_state("state_2"):
	# 	state_temp_updated.emit(state_tag_map["state_2"])
	else:
		state_temp_updated.emit(null)

func _temp_state_all_exit():
	pass
	# c_texture_controller.packed_sprite.packed_sprite_editor.try_switch_texture("Normal")

func 检测外部传入() -> String:
	var result = c_state_machine.current_temp_state_exported
	if result.is_empty():
		return ""
	return result[0]

func 检测贴墙状态(_delta: float) -> bool:
	# 检测碰撞并切换纹理（贴墙效果）
	var player = c_texture_controller.component_body as CharacterBody2D
	var move_vector = movement_input.get_move_vector()

	if player.get_slide_collision_count() > 0 and move_vector.length() > 0:
		var collision = player.get_slide_collision(0)
		var collision_normal = collision.get_normal()
		current_delta += _delta
		var dot_product = move_vector.dot(collision_normal)
		if dot_product < 0:
			if current_delta > 0.5:
				return true
			else:
				return false
		else:
			current_delta = 0
	
	return false
