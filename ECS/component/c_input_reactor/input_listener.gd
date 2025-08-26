## 输入监听器 - 静态玩家系统的输入处理监听
## 在正确的游戏状态下激活玩家实体的输入处理
## 绑定到玩家输入响应组件，只在正常游戏状态下处理输入
## [br][b]编辑者:[/b] Sora
class_name InputListener
extends RefCounted

## 绑定的输入组件
## 指向当前激活的玩家输入响应组件
var binding_input_component: CInputReactor = null

## 检查当前游戏状态，只在正常状态下处理输入
func _listen():
	if binding_input_component != null:
		# 获取当前游戏状态
		var current_gaming_state = SGameState.state_machine._get_leaf_state()
		
		# 只在正常游戏状态下处理输入
		if current_gaming_state is GamingStateNormal:
			binding_input_component._avaliable_in_gaming()
