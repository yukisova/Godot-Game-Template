## @editing: Sora [br]
## @describe: 游戏暂停状态 - 游戏逻辑暂停但UI保持响应的状态
## 
## 该状态在玩家暂停游戏时激活，此时除了UI系统外的所有游戏逻辑都会被冻结。
## 这包括实体移动、AI更新、物理模拟等，但暂停菜单等UI仍然可以正常交互。
## 
## 状态特征：
## - 游戏逻辑暂停更新
## - 实体状态被冻结
## - UI系统保持正常运行
## - 暂停菜单可以交互
## - 时间系统停止计时
## 
## 状态转换条件：
## - 继续游戏信号 → 返回正常游戏状态
## - 重新开始信号 → 重新初始化游戏
## - 退出游戏信号 → 返回主菜单
## 
## 应用场景：
## - 玩家按下暂停键
## - 系统自动暂停（失去焦点等）
## - 调试和测试时的状态检查
@tool
class_name GamingStatePause
extends StateHfsm

## 游戏重试信号
## 当玩家选择重新开始游戏时发出
signal game_retry

## 节点初始化
## 连接重试信号到状态转换逻辑
func _enter_tree() -> void:
	game_retry.connect(func():
		await get_tree().process_frame
		state_transition.emit(get_transition_state())
	)

## 进入暂停状态
## 发出全局暂停信号，通知所有系统进入暂停模式
func _enter():
	# 发出全局游戏暂停信号
	SGameState.game_paused.emit()
	print("游戏状态: 进入暂停状态")

## 退出暂停状态
## 发出继续信号，恢复所有系统的正常运行
func _exit():
	# 发出全局游戏继续信号
	SGameState.game_continue.emit()
	print("游戏状态: 退出暂停状态，恢复游戏运行")
