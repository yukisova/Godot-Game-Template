extends ISystem

signal sub_systems_setup_start ## 游戏启动的逻辑

## 黑板操作信号
signal blackboard_inserted(key: StringName, value: Variant)
signal blackboard_cleaned(key: StringName)


var sub_systems: Dictionary[StringName, SubSystem]

func _setup(): ## 系统初始化
	for i in get_children():
		if i is SubSystem:
			sub_systems[i.keyword] = i
	
	blackboard_inserted.connect(_on_blackboard_insert)
	blackboard_cleaned.connect(_on_blackboard_clean)

	sub_systems_setup_start.connect(func():
		for i in sub_systems.values():
			SLoadAndSave.saving_started.connect(i._save_as)
			i._setup()
		)

func _resetup():
	for i in sub_systems.values():
		i._resetup()

func _process(delta: float) -> void:
	if SGameState.state_machine._get_active_state() is GamingChildStateMachine:
		for i in sub_systems.values():
			i._update(delta)

#region :存档系统，将黑板的信息全部保存下来:
func _save_as() -> Dictionary:
	var result = {}
	result["basic"] = {
		"info" = blackboard_info
	}
	for i in get_children():
		if i.has_method("_save_as"):
			result.merge(i._save_as())
	return {
		"blackboard":result
	}

func _load_by():
	pass
#endregion

## TODO 黑板相关
#region :黑板操作: 黑板本身分为两种, 严格限制接收值类型，与不严格的类型
var blackboard_info = {}

## 插入黑板数据: 要求1. 数据插入后需要出现回声Echo，便于分辨杂项
func _on_blackboard_insert(key: StringName, value: Variant):
	if key == &"": return ## 不允许空
	pass

func _on_blackboard_clean(key: StringName):
	if key == &"": return ## 不允许空
	pass

## 查找数据
func blackboard_data_search():
	pass
#endregion
