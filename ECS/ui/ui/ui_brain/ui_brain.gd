## 角色状态界面UI - 显示玩家属性、背包和装备信息
##
## 该UI是玩家的主要信息查看界面，集成了背包管理、物品展示和角色状态查看等功能。
## 提供直观的网格背包系统和详细的物品信息面板。
##
## 核心功能：
## - 背包物品的网格显示和管理
## - 物品详细信息的查看面板
## - 多标签页的信息分类显示
## - 实时的物品焦点切换效果
## - 键盘快捷键的快速访问
##
## 主要特性：
## - 网格式背包布局系统
## - 动态物品信息更新机制
## - 多标签页信息展示界面
## - 响应式的焦点切换反馈
## - 集成物品交互和管理功能
##
## 使用场景：
## - 玩家背包物品管理
## - 角色属性和状态查看
## - 装备和道具的详细检查
## - 游戏内物品整理和分类
##
## 架构设计：
## - 继承自 [IUi] 基类
## - 集成 [GridInventory] 网格背包系统
## - 基于 [TabContainer] 的多页面管理
## - 与 [InventoryExtension] 的数据绑定
## - 支持 [CStatus] 组件的状态管理
##
## [br][b]编辑者:[/b] Sora
extends IUi

#region UI组件依赖

@export_subgroup("依赖")

## 网格背包组件
## 
## 负责物品的网格化显示和交互管理，类型为 [GridInventory]。
@export var grid_inventory: GridInventory

## 列表容器
## 
## 存放各种列表信息的容器组件，类型为 [ListDocument]。
@export var list_container: ListDocument

## 焦点物品图像组
## 
## 不同标签页的物品图标显示组件数组，类型为 [Array] of [TextureRect]。
@export var focus_item_image: Array[TextureRect]

## 焦点物品名称组
## 
## 不同标签页的物品名称显示组件数组，类型为 [Array] of [Label]。
@export var focus_item_name: Array[Label]

## 焦点物品描述组
## 
## 不同标签页的物品详细描述显示组件数组，类型为 [Array] of [RichTextLabel]。
@export var focus_item_describe: Array[RichTextLabel]

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
	
	# 连接网格背包的焦点物品更新信号
	grid_inventory.focus_item_updated.connect(_on_display_item_info)
	
	print("角色状态UI: 初始化完成")

#endregion

#region UI初始化

## 初始化界面信息
## 
## 根据传入的上下文数据初始化背包和状态显示。
## [param _context]: 包含背包信息的上下文字典，类型为 [Dictionary]
func _initilize_info(_context: Dictionary) -> void:
	await ready
	print("角色状态UI: 开始加载背包数据")
	
	var status:CStatus = _context["status"]
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
## 
## 更新当前标签页的物品信息显示。
## [param item]: 要显示的物品对象，类型为 [Item]
func _on_display_item_info(item: Item):
	var current_tab: int = tab_container.current_tab
	
	# 更新当前标签页的物品信息显示
	focus_item_image[current_tab].texture = item.item_texture
	focus_item_describe[current_tab].text = item.item_description
	focus_item_name[current_tab].text = item.item_name
	
	print("角色状态UI: 更新物品信息 -> ", item.item_name)

#endregion

#region 输入处理

## 处理每帧输入（重写方法）
## 
## 检测键盘输入并响应界面切换操作。
## [param _delta]: 帧时间间隔
func _process(_delta: float) -> void:
	# 检测脑图触发键（通常是Tab键）
	if Input.is_action_just_pressed("brain_trigger"):
		print("角色状态UI: 关闭界面")
		unspawn()

#endregion
