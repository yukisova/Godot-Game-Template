## SORA @editing: Sora [br]
## @describe: 玩家的hfsm根状态机,主要用于实现一些特殊的按键监听 
@tool
extends StateMachineHfsm

@export_group("关联Action","action_")
@export var action_seek: Action ## 

func _update(delta: float) -> void:
	super._update(delta)
	

func _listen():
	pass
