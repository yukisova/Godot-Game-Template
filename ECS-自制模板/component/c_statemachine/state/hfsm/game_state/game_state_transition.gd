## 这是游戏的过渡状态，该状态下
## 1. MapData正在加载环境，需要时间，期间应当按照指定次序加载内容
## 退出条件：
## 1. MapData加载完毕，并发送了相关的信号
@tool
class_name GameStartTransition
extends State
var update_trigger = false

func _update(_delta: float) -> void:
	if update_trigger:
		state_transition.emit(parent_to_self, "")

func _exit():
	update_trigger = false
