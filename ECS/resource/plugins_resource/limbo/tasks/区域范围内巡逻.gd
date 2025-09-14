# 区域范围内巡逻
# 在区域范围内巡逻，并返回巡逻路径
# 参数：
# - 区域：区域ID
# - 巡逻路径：巡逻路径ID
# - 巡逻速度：巡逻速度
# - 巡逻时间：巡逻时间
# - 巡逻距离：巡逻距离
# - 巡逻方向：巡逻方向
# - 巡逻方式：巡逻方式
@tool
extends BTA_TargetJudgment

func _generate_name() -> String:
	return "区域范围内巡逻"

func _setup() -> void:
	var c_behaviour_tree = agent as CBehaviourTree
	blackboard.set_var("c_navigation_agent", c_behaviour_tree.get_other_component(IComponent.ComponentName.C_NAVIGATION_AGENT))

## 进入范围内，设置随机的导航目标
func _enter() -> void:
	var ai_state_normal = blackboard.get_var("ai_state_normal", -1)
	if ai_state_normal != SoraConstant.AiStateNormal.区域巡逻:
		return

	print("敌人进入区域范围内巡逻")

	var c_navigation_agent = blackboard.get_var("c_navigation_agent", null)

	var nav_agent = c_navigation_agent.nav_agent
	var target_position = NavigationServer2D.map_get_random_point(
		nav_agent.get_navigation_map(),
		nav_agent.navigation_layers,
		false)
	print("敌人进入区域范围内巡逻，目标位置: ", target_position)
	c_navigation_agent.set_target_position(target_position)

func _tick(delta: float) -> Status:
	## 1. 判断是否为区域巡逻状态
	var ai_state_normal = blackboard.get_var("ai_state_normal", -1)
	if ai_state_normal != SoraConstant.AiStateNormal.区域巡逻:
		return Status.SUCCESS
	
	## 2. 利用父类方法判断是否需要追击目标
	var target_chase_state : Status = super(delta)
	if target_chase_state != Status.SUCCESS:
		return target_chase_state

	var c_navigation_agent = blackboard.get_var("c_navigation_agent", null)
	var nav_agent = c_navigation_agent.nav_agent
	if nav_agent.is_navigation_finished():
		return Status.FRESH

	## 2. 判断视线范围内是否存在可疑目标
	
	return Status.RUNNING

func _exit() -> void:
	print("敌人退出区域范围内巡逻")
	var c_navigation_agent = blackboard.get_var("c_navigation_agent", null)
	c_navigation_agent.stop_navigation()

## 更新路径
func _update_path():
	pass