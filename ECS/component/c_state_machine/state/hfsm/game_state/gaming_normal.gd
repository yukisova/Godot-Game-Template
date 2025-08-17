## 游戏正常进行状态 - 主要的游戏运行状态
## 
## 该状态代表游戏的正常运行阶段，在此状态下游戏的所有核心逻辑都会正常执行。
## 这是玩家与游戏世界进行交互的主要状态，提供完整的游戏体验。
## 
## 核心功能：
## - 完整的游戏逻辑执行
## - 玩家输入的正常处理
## - 实体系统的完全激活
## - UI界面的正常显示和交互
## - 物理和AI系统的正常运行
## 
## 状态特征：
## - 游戏逻辑正常运行
## - 玩家可以自由移动和操作
## - HUD界面正常显示
## - 实体AI正常工作
## - 物理系统正常更新
## - 音效和音乐正常播放
## 
## 状态转换条件：
## - 游戏暂停信号 → 转入游戏暂停状态
## - 过场剧情开始 → 转入过场剧情状态
## - 游戏结束事件 → 转入结束状态
## - 场景切换请求 → 转入加载状态
## 
## 应用场景：
## - 玩家正常游戏时
## - 战斗进行中
## - 探索和交互阶段
## - 任务执行过程
## - 自由漫游模式
##
## 架构设计：
## - 继承自 [StateHfsm] 基类
## - 使用 [annotation @tool] 支持编辑器功能
## - 基于信号的状态转换机制
## - 与 [SSignalBus] 的游戏循环集成
##
## [br][b]编辑者:[/b] Sora
@tool
class_name GamingStateNormal
extends StateHfsm

## 游戏暂停信号
## 
## 当接收到暂停请求时发出，触发状态切换到暂停状态。
signal game_paused

## 过场剧情开始信号
## 
## 当需要播放过场剧情时发出，触发状态切换到剧情状态。
signal game_cutscene_started

## 状态初始化（重写方法）
## 
## 连接状态转换信号到对应的处理逻辑。
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

## 进入正常游戏状态（重写方法）
## 
## 发出游戏循环继续信号，激活所有游戏系统。
func _enter():
	# 通知所有系统游戏正常运行
	SSignalBus.game_loop_continue.emit()
	print("游戏状态: 进入正常游戏状态")

## 退出正常游戏状态（重写方法）
## 
## 执行必要的清理工作。
func _exit():
	print("游戏状态: 退出正常游戏状态")
	# 基础清理工作在父类中处理
