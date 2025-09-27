@abstract class_name ITriggerAction
extends IAction

signal action_state_output(action: ITriggerAction)

signal action_triggered()
signal action_triggered_finished()

func _enter_tree() -> void:
	if Engine.is_editor_hint(): return
	action_triggered.connect(_trigger_update)
	action_triggered_finished.connect(_trigger_update_finish)

## 行为的核心执行逻辑，当触发条件满足时被调用，子类必须重写此方法
## [param _args]: 可变参数列表，传递行为执行所需的数据
@abstract func _trigger_update(..._args)

## 当触发行为执行完毕时调用的清理方法，子类必须重写此方法
@abstract func _trigger_update_finish()
