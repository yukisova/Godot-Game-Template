extends ISystem

signal blackboard_inserted(key: StringName, value: Variant)
signal blackboard_cleaned(key: StringName)

var sub_systems: Dictionary[ISubSystem.SubSystemType, ISubSystem]

func _process(delta: float) -> void:
	if SGameState.state_machine.get_active_state() is GamingChildStateMachine:
		for subsystem in sub_systems.values():
			subsystem._update(delta)

func _setup():
	for child in get_children():
		if child is ISubSystem:
			sub_systems[child.keyword] = child
	
	blackboard_inserted.connect(_on_blackboard_insert)
	blackboard_cleaned.connect(_on_blackboard_clean)

	SSignalBus.game_loop_start.connect(_on_sub_systems_setup_start)

func _resetup():
	for subsystem in sub_systems.values():
		subsystem._resetup()

func _on_sub_systems_setup_start():
	for subsystem in sub_systems.values():
		subsystem._setup()

func _data_saving(_data: SavedDataFile):
	# TODO: 实现黑板数据的存档逻辑
	_data.blackboard_info = blackboard_info

func _data_loading(_data: SavedDataFile):
	# TODO: 实现黑板数据的读档逻辑
	blackboard_info = _data.blackboard_info

var blackboard_info = {}

func _on_blackboard_insert(key: StringName, _value: Variant):
	if key == &"": 
		push_warning("黑板数据键名不能为空")
		return
	# TODO: 实现数据插入逻辑和回声机制
	pass

func _on_blackboard_clean(key: StringName):
	if key == &"": 
		push_warning("黑板数据键名不能为空")
		return
	# TODO: 实现数据清理逻辑
	pass

func blackboard_data_search():
	# TODO: 实现数据查找逻辑
	pass

func get_sub_system(keyword: ISubSystem.SubSystemType) -> ISubSystem:
	return sub_systems.get(keyword)

