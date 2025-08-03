## @editing: Sora [br]
## @describe: TODO 位于PlayerStatic系统中的用于静态处理玩家的指令的输入监听系统，需要优化
class_name InputListener
extends Node

var binding_input_component : C_InputReactor = null

func _process(_delta: float) -> void:
	if binding_input_component != null:
		_listen()

func _listen():
	var current_gaming_state = SGameState.state_machine._get_leaf_state()
	if current_gaming_state is GamingStateNormal:
		binding_input_component._avaliable_in_gaming()
