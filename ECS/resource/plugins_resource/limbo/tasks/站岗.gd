## 站岗
## 在指定位置站岗，并返回站岗路径
## 参数：
## - 位置：位置ID
## - 站岗时间：站岗时间
## - 站岗方式：站岗方式
@tool
extends BTA_TargetJudgment

func _setup() -> void:
	pass

func _enter() -> void:
	print("敌人在站岗")

func _tick(delta: float) -> Status:

	## 2. 利用父类方法判断是否需要追击目标
	var target_chase_state : Status = super(delta)
	if target_chase_state != Status.SUCCESS:
		return target_chase_state

	return Status.RUNNING
	
	

func _exit() -> void:
	print("敌人停止站岗")
