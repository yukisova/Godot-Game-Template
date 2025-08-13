## @editing: Sora [br]
## @describe: 角色状态界面UI - 显示玩家属性、背包和装备信息
##
## 该UI是玩家的主要信息查看界面，集成了：
## - 背包物品的网格显示和管理
## - 物品详细信息的查看面板
## - 多标签页的信息分类显示
## - 实时的物品焦点切换效果
##
## 主要功能：
## - 背包物品的可视化管理
## - 物品信息的详细展示
## - 标签页切换的界面组织
## - 键盘快捷键的快速访问
##
## 界面特性：
## - 网格式背包布局
## - 动态物品信息更新
## - 多标签页信息展示
## - 快捷键开关控制
extends IUi

#region UI组件依赖

@export_subgroup("依赖")

## 网格背包组件
## 负责物品的网格化显示和交互
@export var grid_inventory: GridInventory

## 列表容器
## 存放各种列表信息的容器组件
@export var list_container: Control

## 焦点物品图像组
## 不同标签页的物品图标显示组件
@export var focus_item_image: Array[TextureRect]

## 焦点物品名称组
## 不同标签页的物品名称显示组件
@export var focus_item_name: Array[Label]

## 焦点物品描述组
## 不同标签页的物品详细描述显示组件
@export var focus_item_describe: Array[RichTextLabel]

#endregion

#region 场景节点引用

## 标签容器
## 管理多个信息标签页的容器
@onready var tab_container: TabContainer = $Control/TabContainer

#endregion

#region UI生命周期

## UI准备就绪
## 连接信号和设置初始状态
func _ready() -> void:
	super()
	print("角色状态UI: 开始初始化")
	
	# 连接网格背包的焦点物品更新信号
	grid_inventory.focus_item_updated.connect(_on_display_item_info)
	
	print("角色状态UI: 初始化完成")

#endregion

#region UI初始化

## 初始化界面信息
## @param _context: 包含背包信息的上下文字典
func _initilize_info(_context: Dictionary) -> void:
	await ready
	print("角色状态UI: 开始加载背包数据")
	
	var status:C_Status = _context["status"]
	var inventory: InventoryExtension = status.status_extension[StatusExtension.ExtensionType.INVENTORY]
	
	grid_inventory.grid_num = inventory.inventory_pack_num
	grid_inventory.col_num = inventory.inventory_pack_col
	
	grid_inventory.binding_status = status
	
	
	# 加载所有背包物品
	for i in inventory.inventory_array:
		if i != null:
			grid_inventory.add_item(i)
	
	print("角色状态UI: 背包数据加载完成")

#endregion

#region 物品信息显示

## 显示物品详细信息
## @param item: 要显示的物品对象
func _on_display_item_info(item: Item):
	var current_tab: int = tab_container.current_tab
	
	# 更新当前标签页的物品信息显示
	focus_item_image[current_tab].texture = item.item_texture
	focus_item_describe[current_tab].text = item.item_description
	focus_item_name[current_tab].text = item.item_name
	
	print("角色状态UI: 更新物品信息 -> ", item.item_name)

#endregion

#region 输入处理

## 处理每帧输入
## @param delta: 帧时间间隔
func _process(_delta: float) -> void:
	# 检测脑图触发键（通常是Tab键）
	if Input.is_action_just_pressed("brain_trigger"):
		print("角色状态UI: 关闭界面")
		unspawn()

#endregion
