##@editing:	Sora
##@describe:	状态基类
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

func _listen(): ## 用于部分状态下的按键监听
	pass
