##@editing:	Sora
##@describe:	Ui
@abstract class_name IUi
extends CanvasLayer

signal _unspawned

@export var is_testing:bool

func _ready() -> void:
	if get_tree().current_scene != self:
		_main_setup()
	else:
		_test_setup()

func _main_setup(): ## 主要运行时，运行的逻辑
	pass

func _test_setup(): ## 单元测试时，运行的逻辑
	pass

func unspawn():
	_unspawned.emit(self)

## 信息初始化
func _initilize_info(_context: Dictionary):
	pass

## 当聚焦于此界面的时候所可以进行的操作
func _focus_listen():
	pass
