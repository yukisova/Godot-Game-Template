extends BTAction

## 发动攻击
func _enter() -> void:
	print("敌人开始发动攻击")
	blackboard.set_var("is_attacking", true)

	await agent.get_tree().create_timer(1.0).timeout
	blackboard.set_var("is_attacking", false)

## 开始发动攻击
func _tick(delta: float) -> Status:
	if blackboard.get_var("is_attacking", false):
		return Status.RUNNING
	else:
		return Status.SUCCESS

func _exit() -> void:
	pass
