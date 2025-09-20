## 指定路径内巡逻
## 在指定路径内巡逻，并返回巡逻路径
## 参数：
## - 路径：路径ID
## - 巡逻速度：巡逻速度
## - 巡逻时间：巡逻时间
## - 巡逻距离：巡逻距离
## - 巡逻方向：巡逻方向
## - 巡逻方式：巡逻方式

@tool
extends BTA_TargetJudgment

func _setup() -> void:
	pass

func _enter() -> void:
	var move_vector: MoveStrategyVector = blackboard.get_var("move_vector", null, false)
	if move_vector:
		move_vector.toward_control_by_move = true

	var ai_state_normal = blackboard.get_var("ai_state_normal", -1)
	if ai_state_normal != SoraConstant.AiStateNormal.路径巡逻:
		return
	print("敌人进入指定路径内巡逻")

func _tick(delta: float) -> Status:
	var ai_state_normal = blackboard.get_var("ai_state_normal", -1)
	if ai_state_normal != SoraConstant.AiStateNormal.路径巡逻:
		return Status.SUCCESS

	## 2. 利用父类方法判断是否需要追击目标
	var target_chase_state : Status = super(delta)
	if target_chase_state != Status.SUCCESS:
		return target_chase_state

	return Status.RUNNING
