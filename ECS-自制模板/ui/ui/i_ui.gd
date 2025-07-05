abstract class_name IUi
extends CanvasLayer

signal unspawned

func unspawn():
	unspawned.emit(self)


func _focus_listen():
	pass
