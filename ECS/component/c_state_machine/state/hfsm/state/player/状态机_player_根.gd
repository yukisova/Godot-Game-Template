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

## 关联的ActionInput组件，用于处理玩家的输入操作，类型为 [ActionInput]。
@export var action_input: ActionInput
@export var c_texture_controller: CTextureController

## 状态输入tag与pda状态的映射关系
@export var state_tag_map: Dictionary[String, StateTemp]

func _blur_update(_delta: float) -> void:
	## 状态机
	if action_input.check_input_state("state_0"):
		state_temp_updated.emit(state_tag_map["state_0"])
	# elif action_input.check_input_state("state_1"):
	# 	state_dynamic_updated.emit(state_tag_map["state_1"])
	# elif action_input.check_input_state("state_2"):
	# 	state_dynamic_updated.emit(state_tag_map["state_2"])
	else:
		state_temp_updated.emit(null)

func _temp_state_all_exit():
	c_texture_controller.packed_sprite.packed_sprite_editor.try_switch_texture("Normal")
