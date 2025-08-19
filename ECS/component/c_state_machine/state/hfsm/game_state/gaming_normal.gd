## 游戏正常进行状态 - 主要的游戏运行状态
## 代表游戏的正常运行阶段，在此状态下游戏的所有核心逻辑都会正常执行
## 核心功能：完整游戏逻辑执行、玩家输入处理、实体系统激活、UI界面交互
## 状态转换：游戏暂停、过场剧情、游戏结束、场景切换
## [br][b]编辑者:[/b] Sora
@tool
class_name GamingStateNormal
extends StateHfsm

## 游戏暂停信号，当接收到暂停请求时发出
signal game_paused

## 过场剧情开始信号，当需要播放过场剧情时发出
signal game_cutscene_started

## 状态初始化，连接状态转换信号到对应的处理逻辑
func _ready() -> void:
	# 连接暂停信号
	game_paused.connect(func():
		await get_tree().process_frame
		var pause_state = get_transition_state("pause")
		if pause_state:
			state_transition.emit(pause_state)
	)
	
	# 连接过场剧情信号
	game_cutscene_started.connect(func():
		await get_tree().process_frame
		var cutscene_state = get_transition_state("cutscene")
		if cutscene_state:
			state_transition.emit(cutscene_state)
	)

## 进入正常游戏状态，发出游戏循环继续信号，激活所有游戏系统
func _enter():
	# 通知所有系统游戏正常运行
	SSignalBus.game_loop_continue.emit()
	print("游戏状态: 进入正常游戏状态")

## 退出正常游戏状态，执行必要的清理工作
func _exit():
	print("游戏状态: 退出正常游戏状态")
	# 基础清理工作在父类中处理
