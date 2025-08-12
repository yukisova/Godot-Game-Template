## @editing: Sora [br]
## @describe: 状态基类
@abstract class_name State
extends Node

func _enter():
	pass

func _update(_delta: float) -> void:
	pass

func _fixed_update(_delta: float) -> void:
	pass

func _exit():
	pass

func _blur_update(_delta: float): ## 
	pass

func _pause():
	pass

func _continue():
	pass
