## 角色状态界面UI - 显示玩家属性、背包和装备信息
## 该UI是玩家的主要信息查看界面，集成了背包管理、物品展示和角色状态查看等功能。
## 架构设计:
## - 继承自 [IUi] 基类
## - 集成 [GridInventory] 网格背包系统
## - 基于 [TabContainer] 的多页面管理
## - 与 [InventoryExtension] 的数据绑定
## - 支持 [CStatusList] 组件的状态管理
##
## [br][b]编辑者:[/b] Sora
extends IUi

#region UI组件依赖

@export_subgroup("依赖")

## 网格背包组件
## 
## 负责物品的网格化显示和交互管理，类型为 [GridInventory]。
@export var grid_inventory: GridInventory

@export var panel_button_weapon_prototype: PanelButtonWeapon
@export var item_weapon_list: VBoxContainer

## 列表容器
## 
## 存放各种列表信息的容器组件，类型为 [ListDocument]。
@export var list_container: ListDocument

#endregion

#region 场景节点引用

## 标签容器
## 
## 管理多个信息标签页的容器，类型为 [TabContainer]。
@onready var tab_container: TabContainer = $Control/TabContainer

#endregion

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
	
	grid_inventory.grid_num = inventory.inventory_pack_num
	grid_inventory.col_num = inventory.inventory_pack_col
	
	grid_inventory.binding_status = status
	
	# 加载所有背包物品
	for i in inventory.inventory_array:
		if i != null:
			grid_inventory.add_item(i)
	
	for i:ItemWeapon in inventory.inventory_array_weapon.values():
		if i != null:
			# 1. 根据按钮的原型，复制并绑定按钮信息
			var new_button: PanelButtonWeapon = panel_button_weapon_prototype.duplicate()
			item_weapon_list.add_child(new_button)
			new_button.binding_item = i
			new_button.target_c_status = status
			new_button.button.pressed.connect(new_button.button_func.bind({}))
	# 2. 加载装备数据
	var equipment: EquipmentExtension = status.status_extension[StatusExtension.ExtensionType.EQUIPMENT]
	if equipment:
		equipment.equipment_node_changed.connect(_on_equipment_node_changed)
		equipment.attack_node_changed.connect(_on_attack_node_changed)

		if equipment.current_weapon and equipment.current_weapon.equipment_control:
			grid_inventory.equipment_control = equipment.current_weapon.equipment_control.instantiate()
			grid_inventory.equipment_control.binding_equipment = equipment.current_weapon
			grid_inventory.equipment_control._initialize()

func _on_equipment_node_changed(item_equipment: ItemEquipment):
	pass

func _on_attack_node_changed(item_weapon: ItemWeapon):
	grid_inventory.equipment_control = item_weapon.equipment_control.instantiate()
	grid_inventory.equipment_control.binding_equipment = item_weapon
	grid_inventory.equipment_control._initialize()

#endregion

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
