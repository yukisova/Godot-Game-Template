## 触发行为基类 - 一次性触发行为的抽象接口
##
## 该抽象类为所有触发行为提供统一的框架。触发行为是响应特定事件的一次性行为，
## 如技能释放、道具使用、环境交互等。与持续行为不同，触发行为有明确的开始和结束。
##
## 行为生命周期：
## 1. 触发条件满足 → 发出 [signal action_triggered] 信号
## 2. 执行行为逻辑 → 调用 [method _trigger_update]
## 3. 行为完成 → 调用 [method _trigger_update_finish]
## 4. 清理状态 → 发出 [signal action_triggered_finished] 信号
##
## 功能特性：
## - 信号驱动的触发机制
## - 可变参数的灵活执行
## - 自动状态管理和清理
## - 与 [CActionTrigger] 组件集成
##
## 行为分类：
## - [b]技能行为[/b]：技能释放、施法、攻击等
## - [b]道具行为[/b]：使用道具、装备武器等
## - [b]交互行为[/b]：开门、拾取、对话等
## - [b]效果行为[/b]：播放特效、音效、动画等
##
## 适用场景：
## - 技能释放时的效果处理
## - 道具使用的逻辑执行
## - 环境交互的行为响应
## - UI操作的后端处理
## - 事件系统的行为触发
##
## 架构设计：
## - 继承自 [IAction] 基类
## - 基于信号的异步通信机制
## - 支持运行时动态参数传递
## - 与ECS组件系统无缝集成
##
## [br][b]编辑者:[/b] Sora
@abstract class_name TriggerAction
extends IAction

## 行为触发信号
## 
## 当触发行为开始执行时发出的信号，用于通知 [CActionTrigger] 组件
## 将此行为添加到当前行为列表中，开始状态跟踪。
## [param action]: 触发的行为实例，类型为 [TriggerAction]
signal action_triggered(action: TriggerAction)

## 行为完成信号
## 
## 当触发行为执行完毕时发出的信号，用于通知 [CActionTrigger] 组件
## 将此行为从当前行为列表中移除，完成状态清理。
## [param action]: 完成的行为实例，类型为 [TriggerAction]
signal action_triggered_finished(action: TriggerAction)


## 触发行为更新（抽象方法）
## 
## 行为的核心执行逻辑，当触发条件满足时被调用。子类必须重写此方法
## 来实现具体的行为效果，如技能释放、道具使用、交互响应等。
## 
## 执行时机：
## - 在 [signal action_triggered] 信号发出后调用
## - 通常在用户操作或事件触发后立即执行
## - 支持同步和异步执行模式
## 
## 参数传递：
## - 支持可变参数列表，灵活传递执行所需的数据
## - 常见参数：目标对象、效果强度、持续时间等
## - 参数类型和数量由具体行为子类定义
## 
## 实现要点：
## - 实现具体的行为逻辑
## - 处理执行过程中的错误情况
## - 确保执行完成后调用 [method _trigger_update_finish]
## - 避免长时间阻塞，必要时使用异步处理
## 
## [param _args]: 可变参数列表，传递行为执行所需的数据
## 
## [br][b]示例实现:[/b]
## [codeblock]
## func _trigger_update(target: Node, damage: int):
##     # 实现攻击行为逻辑
##     target.take_damage(damage)
##     play_attack_effect()
##     _trigger_update_finish()
## [/codeblock]
@abstract func _trigger_update(..._args)

## 触发行为完成（抽象方法）
## 
## 当触发行为执行完毕时调用的清理方法。子类必须重写此方法
## 来处理行为完成后的清理工作和状态重置。
## 
## 调用时机：
## - 在 [method _trigger_update] 执行完成后调用
## - 在发出 [signal action_triggered_finished] 信号前调用
## - 标志着行为生命周期的结束
## 
## 主要职责：
## - 清理行为执行过程中产生的临时数据
## - 重置行为状态为初始状态
## - 释放占用的资源（如纹理、音频等）
## - 发出完成信号通知其他系统
## 
## 实现要点：
## - 确保所有资源得到正确释放
## - 重置所有状态变量到初始值
## - 处理异常情况的清理工作
## - 避免重复调用导致的问题
## 
## [br][b]示例实现:[/b]
## [codeblock]
## func _trigger_update_finish():
##     # 清理临时效果
##     stop_all_effects()
##     # 重置状态
##     current_action_state = action_states[0]
##     # 发出完成信号
##     action_triggered_finished.emit(self)
## [/codeblock]
@abstract func _trigger_update_finish()