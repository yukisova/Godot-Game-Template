extends BTAction

## 发动攻击
func _enter() -> void:
	blackboard.set_var("is_attacking", true)
	var attack_action: AttackAction = blackboard.get_var("attack_action", null)
	if attack_action:
		attack_action.action_triggered.emit(attack_action)
	
	await attack_action.action_triggered_finished
	blackboard.set_var("is_attacking", false)


## 开始发动攻击
func _tick(delta: float) -> Status:
	if blackboard.get_var("is_attacking", false):
		return Status.RUNNING
	else:
		return Status.SUCCESS

func _exit() -> void:
	print("完成攻击-发动攻击.gd-exit")
