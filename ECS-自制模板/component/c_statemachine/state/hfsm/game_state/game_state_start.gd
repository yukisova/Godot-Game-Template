## 游戏的开始状态，该状态下
## 1. 并未加载游戏场景，只会运行UI，当S_MapData启动时，即说明完成加载游戏主场景，可以开始游戏
## 退出条件：
## 1. 游戏主场景加载，并发送了相关的信号
## 2. 游戏退出
@tool
class_name GameStartState
extends State
var update_trigger = false

func _update(_delta: float) -> void:
	if update_trigger:
		state_transition.emit(parent_to_self, "")


func _exit():
	update_trigger = false
