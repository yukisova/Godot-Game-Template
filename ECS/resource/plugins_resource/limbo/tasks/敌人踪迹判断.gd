@tool
## 目标判断
class_name BTA_TargetJudgment
extends BTAction

func _tick(delta: float) -> Status:
	var sight_box: SightBox = blackboard.get_var("sight_box", null, false)
	if sight_box:
		if !sight_box.sight_target.is_empty():
			## 发现可疑目标，停止区域范围内巡逻，并进一步确认目标
			return Status.FAILURE
	else:
		print("敌人没有视觉")
	
	## 3. 判断听觉范围内是否存在可疑声音
	var sound_box: SoundBox = blackboard.get_var("sound_box", null, false)
	if sound_box:
		## 听见可疑声音，停止区域范围内巡逻，并进一步确认声音来源
		if !sound_box.sound_target.is_empty():
			return Status.FAILURE
	else:
		print("敌人没有听觉")
	return Status.SUCCESS
