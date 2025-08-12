##@editing:	Sora
##@describe:	人物状态界面UI
extends IUi

@export_subgroup("测试用")
@export var inventory: Array[Item]

@export_subgroup("依赖")
@export var grid_inventory: GridInventory
@export var list_container: Control
@export var focus_item_image: Array[TextureRect]
@export var focus_item_name: Array[Label]
@export var focus_item_describe: Array[RichTextLabel]

@onready var tab_container: TabContainer = $Control/TabContainer

func _ready() -> void:
	super()
	grid_inventory.focus_item_updated.connect(_on_display_item_info)

func _test_setup():
	_initilize_info({
		"inventory": inventory,
	})

	

## 应当传入的动态参数:
## 角色当前的背包内容与每个物品的编排位置
func _initilize_info(_context: Dictionary) -> void:
	await ready
	var inventory = _context["inventory"] as InventoryExtension
	grid_inventory.grid_num = inventory.inventory_pack_num
	for i in inventory.inventory_array:
		if i != null:
			grid_inventory.add_item(i)

func _on_display_item_info(item: Item):
	var current_tab: int = tab_container.current_tab
	focus_item_image[current_tab].texture = item.item_texture
	focus_item_describe[current_tab].text = item.item_description
	focus_item_name[current_tab].text = item.item_name


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("brain_trigger"):
		unspawn()
