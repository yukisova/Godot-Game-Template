## 站岗
## 在指定位置站岗，并返回站岗路径
## 参数：
## - 位置：位置ID
## - 站岗时间：站岗时间
## - 站岗方式：站岗方式
@tool
extends BTAction

func _setup() -> void:
	pass

func _enter() -> void:
	print("敌人在站岗")

func _tick(delta: float) -> Status:
	## 1. 判断视线范围内是否存在可疑目标
	var sight_box: SightBox = blackboard.get_var("sight_box", null, false)
	if sight_box:
		if !sight_box.sight_target.is_empty():
			## 发现可疑目标，停止站岗，并进一步确认目标
			return Status.FAILURE

	else:
		print("敌人没有视觉")
	var sound_box: SoundBox = blackboard.get_var("sound_box", null, false)
	if sound_box:
		## 听见可疑声音，停止站岗，并进一步确认声音来源
		if !sound_box.sound_target.is_empty():
			return Status.FAILURE
	else:
		print("敌人没有听觉")
	return Status.RUNNING
	
	

func _exit() -> void:
	print("敌人停止站岗")
