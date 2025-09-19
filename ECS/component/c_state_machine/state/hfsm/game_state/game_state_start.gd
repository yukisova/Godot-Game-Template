## 游戏开始状态 - 游戏启动时的初始状态实现
##
## 该状态下系统仅运行UI界面，等待游戏主场景的加载完成。
## 当 [SMapData] 启动时，表示游戏主场景加载完成，可以开始游戏。
##
## 状态特性：
## - 只运行UI系统，不加载游戏场景
## - 监听地图数据系统的启动信号
## - 作为游戏流程的入口状态
##
## 退出条件：
## 1. 游戏主场景加载完成，并发送了相关的信号
## 2. 游戏退出请求
##
## 架构设计：
## - 继承自 [StateHfsm] 基类
## - 使用 [annotation @tool] 支持编辑器预览
## - 通过触发器控制状态转换
## - 与地图数据系统协调启动流程
##
## [br][b]编辑者:[/b] Sora
@tool
class_name GameStartState
extends StateHfsm

var update_trigger = false

func _continue() -> void:
	pass

func _enter() -> void:
	pass

func _fixed_update(_delta: float) -> void:
	pass

func _update(_delta: float) -> void:
	if update_trigger:
		state_transition.emit(get_transition_state())

func _exit() -> void:
	update_trigger = false
	pass

func _blur_update(_delta: float) -> void:
	pass

func _pause() -> void:
	pass