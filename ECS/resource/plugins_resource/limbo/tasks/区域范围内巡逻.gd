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
extends BTAction


var c_navigation: CNavigationAgent

@export var update_time: float = 0.3

func _generate_name() -> String:
	return "区域范围内巡逻"

func _setup() -> void:
	var c_behaviour_tree = agent as CBehaviourTree
	c_navigation = c_behaviour_tree.get_other_component(IComponent.ComponentName.C_NAVIGATION_AGENT)

## 进入范围内，设置随机的导航目标
func _enter() -> void:
	var ai_state_normal = blackboard.get_var("ai_state_normal", -1)
	if ai_state_normal != SoraConstant.AiStateNormal.区域巡逻:
		return

	print("敌人进入区域范围内巡逻")

	# c_navigation.nav_agent.navigation_layers = Main.NavigationLayer.Zone

	# var zone : NavigationRegion2D= blackboard.get_var("navigation_region", null)
	var zone = blackboard.get_var("navigation_region", null)

	var nav_agent = c_navigation.nav_agent
	var target_position = NavigationServer2D.map_get_random_point(
		nav_agent.get_navigation_map(),
		nav_agent.navigation_layers,
		false)
	print("敌人进入区域范围内巡逻，目标位置: ", target_position)
	c_navigation.set_target_position(target_position)

func _tick(delta: float) -> Status:
	## 1. 判断是否为区域巡逻状态
	var ai_state_normal = blackboard.get_var("ai_state_normal", -1)
	if ai_state_normal != SoraConstant.AiStateNormal.区域巡逻:
		return Status.SUCCESS

	var nav_agent = c_navigation.nav_agent
	if nav_agent.is_navigation_finished():
		return Status.FRESH

	## 2. 判断视线范围内是否存在可疑目标
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
	return Status.RUNNING

## 更新路径
func _update_path():
	pass

