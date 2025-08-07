## @editing: Sora [br]
## @describe: 全局信号总线系统
extends ISystem

@warning_ignore("unused_signal")
signal map_info_loaded ## 游戏已经完成了地图数据信息的加载，下一步是初始化所有实体-> 刷新Hud状态
@warning_ignore("unused_signal")
signal entity_initialize_started ## 玩家角色成功放入地图，可以正式开始初始化所有的实体
signal game_data_loaded_compelete ## 实体初始化完毕，已经可以正常开始游戏

@warning_ignore("unused_signal")
signal game_loop_start ## 游戏循环开始
@warning_ignore("unused_signal")
signal game_loop_continue ## 游戏循环继续，进入游戏内循环
@warning_ignore("unused_signal")
signal game_loop_paused ## 游戏暂停，此时会隐藏HUD信息

@warning_ignore("unused_signal")
signal ui_main_returned ## 因为游戏失败或通过暂停界面结束游戏时，所进入的状态

## 系统启动
func _setup():
	game_data_loaded_compelete.connect(func():
		var game_state_machine = SGameState.state_machine
		await game_state_machine.state_transition_finished
		var current_state = game_state_machine._get_leaf_state()
		if current_state is GameStartTransition:
			current_state.update_trigger = true
		else:
			printerr("WTF错误: gameloaded触发后按理来说一定是在GameStartTransition下，当前状态", current_state.name)
		)
