## 触发行为基类 - 一次性触发行为的抽象接口
## 该抽象类为所有触发行为提供统一的框架，触发行为是响应特定事件的一次性行为
## 如技能释放、道具使用、环境交互等，与持续行为不同，触发行为有明确的开始和结束
## 行为生命周期：触发条件满足→发出信号→执行逻辑→行为完成→清理状态
## 功能特性：信号驱动的触发机制、可变参数的灵活执行、自动状态管理和清理
## 行为分类：技能行为、道具行为、交互行为、效果行为
## 架构设计：继承自 [IAction] 基类，基于信号的异步通信机制
## [br][b]编辑者:[/b] Sora
@abstract class_name ITriggerAction
extends IAction

## 行为触发信号
## 当触发行为开始执行时发出，通知 [CActionTrigger] 组件将此行为添加到当前行为列表中
signal action_triggered(action: ITriggerAction)

## 行为完成信号
## 当触发行为执行完毕时发出，通知 [CActionTrigger] 组件将此行为从当前行为列表中移除
signal action_triggered_finished(action: ITriggerAction)


## 行为的核心执行逻辑，当触发条件满足时被调用，子类必须重写此方法
## [param _args]: 可变参数列表，传递行为执行所需的数据
@abstract func _trigger_update(..._args)

## 当触发行为执行完毕时调用的清理方法，子类必须重写此方法
@abstract func _trigger_update_finish()
