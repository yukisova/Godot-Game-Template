@abstract class_name IUi
extends CanvasLayer

signal unspawned

func unspawn():
	unspawned.emit(self)

## 信息初始化
func _initilize_info(_context: Dictionary):
	pass

## 当聚焦于此界面的时候所可以进行的操作
func _focus_listen():
	pass
