## @editing: Sora [br]
## @describe: 输入监听器 - 为静态玩家系统处理输入指令的监听系统
## 
## 该监听器作为主控制器系统的一部分，负责在正确的游戏状态下
## 激活玩家实体的输入处理。确保输入只在合适的时机被处理。
## 
## 工作机制：
## - 绑定到玩家的输入响应组件
## - 监控游戏状态变化
## - 只在GamingStateNormal状态下处理输入
## - 作为输入系统的中央调度器
## 
## 使用场景：
## - 玩家角色输入处理
## - 游戏状态敏感的输入控制
## - 输入系统的生命周期管理
## 
## TODO: 需要优化架构设计，考虑更灵活的输入管理方式
class_name InputListener
extends Node

## 绑定的输入组件
## 指向当前激活的玩家输入响应组件
var binding_input_component: C_InputReactor = null

## 主循环处理
## 检查输入组件绑定状态并调用输入监听
## @param _delta: 帧时间间隔
func _process(_delta: float) -> void:
	if binding_input_component != null:
		_listen()

## 输入监听逻辑
## 检查当前游戏状态，只在正常游戏状态下处理输入
func _listen():
	# 获取当前游戏状态
	var current_gaming_state = SGameState.state_machine._get_leaf_state()
	
	# 只在正常游戏状态下处理输入
	if current_gaming_state is GamingStateNormal:
		binding_input_component._avaliable_in_gaming()
