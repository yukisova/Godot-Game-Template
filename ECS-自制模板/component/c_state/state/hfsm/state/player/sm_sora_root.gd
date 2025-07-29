##@editing:	Sora
##@describe:	玩家的hfsm根状态机,主要用于实现一些特殊的按键监听 
@tool
extends StateMachineHfsm

@export var splat: Action ## 史莱姆发射
@export var charge: Action ## 魔力补充行为

func _update(delta: float) -> void:
	super._update(delta)
	

func _listen():
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)): ## 发射
		splat._effect()
		print("按住了发射按钮")
	elif (Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)): ## 框选
		print("按住了框选按钮")
	elif (Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)):
		print("按住了充能按钮")
		charge._effect()
		
