@tool
extends BTAction

func _generate_name() -> String:
	return "正式进入警戒状态"

## 警戒状态下，敌人会停止将移动方向作为面朝的方向，而是面朝主要追踪目标
func _enter() -> void:
	print("敌人正式进入警戒状态")
	var c_action_trigger: CActionTrigger = agent.get_other_component(IComponent.ComponentName.C_ACTION_TRIGGER)
	if c_action_trigger:
		for move_strategy in c_action_trigger.move_strategy:
			if move_strategy is MoveStrategyVector:
				move_strategy.toward_control_by_move = false
				blackboard.set_var("move_vector", move_strategy)

func _tick(delta: float) -> Status:
	var move_vector: MoveStrategyVector = blackboard.get_var("move_vector", null, false)
	## 1. 判断视线范围内是否存在可疑目标
	var sight_box: SightBox = blackboard.get_var("sight_box", null, false)
	if sight_box:
		if sight_box.sight_target.is_empty():
			## 可疑目标消失，离开警戒状态
			return Status.SUCCESS
		else:
			var target_direction: Vector2 = sight_box.get_target_direction()
			if !target_direction.is_zero_approx():
				move_vector._set_target_direction(null, target_direction)
	else:
		print("敌人没有视觉")

	# var sound_box: SoundBox = blackboard.get_var("sound_box", null, false)
	# if sound_box:
	# 	## 可疑声音消失，离开警戒状态
	# 	if sound_box.sound_target.is_empty():
	# 		return Status.SUCCESS
	# else:
	# 	print("敌人没有听觉")
	return Status.RUNNING

func _exit() -> void:
	print("敌人退出正式警戒状态")
	var move_vector: MoveStrategyVector = blackboard.get_var("move_vector", null, false)
	if move_vector:
		move_vector.toward_control_by_move = true