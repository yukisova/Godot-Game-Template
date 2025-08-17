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

## 更新触发器
## 
## 控制状态转换的触发标志，当设置为true时将触发状态转换。
var update_trigger = false

## 状态更新（重写方法）
## 
## 检查更新触发器并在满足条件时触发状态转换。
## [param _delta]: 帧时间间隔
func _update(_delta: float) -> void:
	if update_trigger:
		state_transition.emit(get_transition_state())

## 退出状态（重写方法）
## 
## 重置更新触发器，为下次进入状态做准备。
func _exit():
	update_trigger = false
