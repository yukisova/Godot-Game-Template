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
extends BTAction

func _setup() -> void:
	var c_behaviour_tree = agent as CBehaviourTree
	var c_navigation = c_behaviour_tree.get_other_component(IComponent.ComponentName.C_NAVIGATION_AGENT)

func _enter() -> void:
	var ai_state_normal = blackboard.get_var("ai_state_normal", -1)
	if ai_state_normal != SoraConstant.AiStateNormal.路径巡逻:
		return
	print("敌人进入指定路径内巡逻")

func _tick(delta: float) -> Status:
	var ai_state_normal = blackboard.get_var("ai_state_normal", -1)
	if ai_state_normal != SoraConstant.AiStateNormal.路径巡逻:
		return Status.SUCCESS

	return Status.RUNNING
