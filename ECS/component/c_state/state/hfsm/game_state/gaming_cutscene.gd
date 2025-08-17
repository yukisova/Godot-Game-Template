## 游戏过场剧情状态 - 管理游戏中的过场动画和剧情播放
##
## 该状态在播放过场剧情时激活，提供受限的用户交互能力。
## 玩家可以进入暂停状态（打开菜单），但不能打开角色状态界面等游戏UI。
##
## 核心功能：
## - 过场剧情的播放和管理
## - 受限的用户交互控制
## - 游戏重试机制的支持
## - 与暂停系统的集成
##
## 状态特征：
## - 剧情播放优先级最高
## - 限制部分UI功能的访问
## - 保持基本的暂停和菜单功能
## - 支持剧情中断和重试
##
## 交互限制：
## - ✅ 可以打开暂停菜单
## - ✅ 可以进行基本设置
## - ❌ 不能打开角色状态界面
## - ❌ 不能进行物品管理
##
## 架构设计：
## - 继承自 [StateHfsm] 基类
## - 使用 [annotation @tool] 支持编辑器功能
## - 基于信号的游戏重试机制
## - 与状态转换系统的集成
##
## [br][b]编辑者:[/b] Sora
@tool
class_name GamingStateCutscene
extends StateHfsm
	
## 游戏重试信号
## 
## 当玩家在过场剧情中选择重试时发出。
signal game_retryed

## 节点初始化（重写方法）
## 
## 连接游戏重试信号到状态转换逻辑。
func _enter_tree() -> void:
	game_retryed.connect(func():
		await get_tree().process_frame
		state_transition.emit(get_transition_state())
		)
