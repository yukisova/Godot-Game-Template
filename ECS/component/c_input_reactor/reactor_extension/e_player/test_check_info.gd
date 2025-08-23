## 测试检查信息扩展 - 开发调试时的信息查看工具
##
## 该扩展提供了开发期间常用的调试功能，包括查看游戏状态和测试存档功能。
## 主要用于开发阶段的系统状态检查和功能测试。
##
## 核心功能：
## - 游戏状态机的实时状态查看
## - 存档系统的手动触发测试
## - 开发调试的便捷快捷键
## - 系统状态的快速诊断
##
## 快捷键功能：
## - [b]KEY_1[/b]：查看全局状态机的当前叶状态
## - [b]test_saving[/b]：手动触发存档保存流程
##
## 调试特性：
## - 实时状态显示：显示状态机的当前状态名称
## - 存档测试：快速测试存档系统的响应
## - 控制台输出：直接在控制台显示调试信息
## - 开发便利性：提供开发期间的快速检查功能
##
## 应用场景：
## - 开发阶段的状态机调试
## - 存档系统的功能测试
## - 游戏流程的状态验证
## - 系统集成的问题排查
## - 功能开发的辅助工具
##
## 架构设计：
## - 继承自 [ReactorExtension] 基类
## - 与 [SGameState] 状态系统集成
## - 与 [SLoadAndSave] 存档系统集成
## - 基于输入事件的触发机制
##
## [br][b]注意:[/b] 此扩展主要用于开发调试，发布版本中可考虑移除
##
## [br][b]编辑者:[/b] Sora
extends ReactorExtension

func _setup():
	pass

## 监听调试输入（重写方法）
## 
## 处理开发调试相关的输入操作。
func _listen():
	if Input.is_key_pressed(KEY_1):
		# 查看全局状态机现在的状态
		var state = SGameState.state_machine._get_leaf_state()
		print("当前游戏状态: ", state.name)
	elif c_input_reactor.validate_control("test_saving", SoraConstant.InputType.JUST_PRESSED, true):
		# 手动触发存档保存
		print("测试: 手动触发存档保存")
		SLoadAndSave.saving_started.emit()
	elif Input.is_key_pressed(KEY_2):
		var action_trigger: CActionTrigger = c_input_reactor.component_owner.list_base_components.get(IComponent.ComponentName.C_ACTION_TRIGGER, null)
		if action_trigger:
			print("当前行为: ", action_trigger.current_action_list)
