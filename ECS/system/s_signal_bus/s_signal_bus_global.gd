## 全局信号总线系统 - 系统间事件通信的中央枢纽
## 该系统作为游戏中所有重要事件的通信中心，提供统一的信号管理和分发机制，允许不同系统之间通过事件进行松耦合的通信
## 核心功能：游戏生命周期事件管理、数据加载状态通知、游戏循环控制信号、UI状态变化通知
## 事件分类：数据加载事件（地图加载、实体初始化等）、游戏循环事件（开始、暂停、继续等）、UI状态事件（界面切换、菜单返回等）
## [br][b]编辑者:[/b] Sora
extends ISystem

## 地图信息加载完成信号
## 游戏已经完成了地图数据信息的加载，下一步是初始化所有实体并刷新HUD状态
@warning_ignore("unused_signal")
signal map_info_loaded

## 实体初始化开始信号
## 玩家角色成功放入地图，可以正式开始初始化所有的实体
@warning_ignore("unused_signal")
signal entity_initialize_started

## 游戏数据加载完成信号
## 实体初始化完毕，已经可以正常开始游戏
signal game_data_loaded_compelete

## 游戏循环开始信号
## 标志着游戏主循环的正式启动
@warning_ignore("unused_signal")
signal game_loop_start

## 游戏循环继续信号
## 游戏循环继续，进入游戏内循环状态
@warning_ignore("unused_signal")
signal game_loop_continue

## 游戏循环暂停信号
## 游戏暂停，此时会隐藏HUD信息
@warning_ignore("unused_signal")
signal game_loop_paused

## 主界面返回信号
## 因为游戏失败或通过暂停界面结束游戏时，进入的状态
@warning_ignore("unused_signal")
signal ui_main_returned

## 系统启动—初始化信号总线系统，建立事件监听和响应机制
func _setup():
	# 连接游戏数据加载完成信号的处理逻辑
	game_data_loaded_compelete.connect(func():
		var game_state_machine = SGameState.state_machine
		var current_state = game_state_machine.get_active_state()
		
		# 处理进入游戏加载地图的情况
		if current_state is GameStartState:
			await game_state_machine.state_transition_finished
			current_state = game_state_machine.get_active_state()
			if current_state is GameStartTransition:
				current_state.update_trigger = true
			else:
				printerr("信号总线错误: gameloaded触发后应该在GameStartTransition状态，当前状态: ", current_state.name)
		
		# TODO: 处理切换地图的情况
		#elif current_state is GamingChildStateMachine:
		#	...
		)
