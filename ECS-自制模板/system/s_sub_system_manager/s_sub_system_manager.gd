extends ISystem

signal sub_systems_setup_start ## 游戏启动的逻辑

var sub_systems: Dictionary[StringName, SubSystem]

func _setup(): ## 系统初始化
	for i in get_children():
		if i is SubSystem:
			sub_systems[i.keyword] = i
	
	sub_systems_setup_start.connect(func():
		for i in sub_systems.values():
			i._setup()
		)

func _resetup():
	for i in sub_systems.values():
		i._resetup()

func _process(delta: float) -> void:
	if SGameState.state_machine._get_active_state() is GamingChildStateMachine:
		for i in sub_systems.values():
			i._update(delta)
