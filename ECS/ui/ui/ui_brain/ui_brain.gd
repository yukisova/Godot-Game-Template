extends UIController

#region UI生命周期
func _ready() -> void:
	super()
	

#endregion

#region UI初始化

func _initilize_info(_context: Dictionary) -> void:
	# 1. 加载背包数据
	var status: CStatusList = _context["status"]

	var inventory: InventoryExtension = status.status_extension[StatusExtension.ExtensionType.INVENTORY]
	var equipment: EquipmentExtension = status.status_extension[StatusExtension.ExtensionType.EQUIPMENT]
	var context: Dictionary = {
		"equipment": equipment,
		"inventory": inventory
	}

	ui_view._initialize(context)
	ui_model._initialize(context)
	
	_bind_model_view()

#endregion

func _bind_model_view():
	ui_model.equipment_node_changed.connect(ui_view._on_equipment_node_changed)
	ui_model.attack_node_changed.connect(ui_view._on_attack_node_changed)

#region 输入处理

func _process(_delta: float) -> void:
	# 检测脑图触发键（通常是Tab键）
	if SGlobalConfig.is_action_triggered(SoraConstant.InputTarget.COMMON, "brain_trigger", SoraConstant.InputType.JUST_PRESSED):
		print("角色状态UI: 关闭界面")
		unspawn()

#endregion
