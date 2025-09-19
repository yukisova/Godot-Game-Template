## 角色状态界面UI - 显示玩家属性、背包和装备信息
## 该UI是玩家的主要信息查看界面，集成了背包管理、物品展示和角色状态查看等功能。
## 架构设计:
## - 继承自 [UIController] 基类
## - 集成 [GridInventory] 网格背包系统
## - 基于 [TabContainer] 的多页面管理
## - 与 [InventoryExtension] 的数据绑定
## - 支持 [CStatusList] 组件的状态管理
##
## [br][b]编辑者:[/b] Sora
extends UIController

#region UI生命周期
## UI准备就绪（重写方法）
## 
## 连接信号和设置初始状态。
func _ready() -> void:
	super()
	print("角色状态UI: 开始初始化")
	
	# # 连接网格背包的焦点物品更新信号
	# grid_inventory.focus_item_updated.connect(_on_display_item_info)
	
	print("角色状态UI: 初始化完成")

#endregion

#region UI初始化

## 初始化界面信息
## 
## 根据传入的上下文数据初始化背包和状态显示。
## [param _context]: 包含背包信息的上下文字典，类型为 [Dictionary]
func _initilize_info(_context: Dictionary) -> void:
	await ready

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

## 处理每帧输入（重写方法）
## 
## 检测键盘输入并响应界面切换操作。
## [param _delta]: 帧时间间隔
func _process(_delta: float) -> void:
	# 检测脑图触发键（通常是Tab键）
	if SGlobalConfig.is_action_triggered(SoraConstant.InputTarget.COMMON, "brain_trigger", SoraConstant.InputType.JUST_PRESSED):
		print("角色状态UI: 关闭界面")
		unspawn()

#endregion
