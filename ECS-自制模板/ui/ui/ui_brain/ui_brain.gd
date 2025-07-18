extends IUi

@export_subgroup("测试用")
@export var is_testing: bool
@export var inventory: Array[Item]
@export var test_num: int

@export_subgroup("依赖")
@export var grid_container: GridContainer

var the_grid_panel_offset: Vector2

const inventory_button_scene: PackedScene = preload("res://ui/ui/ui_brain/composite/grid_inventory/changable_slot.tscn")
var inventory_matrix: Array[Array]


func _ready() -> void:
	if is_testing:
		_initilize_info({
			"inventory": inventory,
			"inventory_num": test_num
		})

## 应当传入的动态参数:
## 角色当前的背包内容与每个物品的编排位置
func _initilize_info(_context: Dictionary) -> void:
	
	
	var grid_panel = grid_container.get_child(0).duplicate() as PanelContainer
	grid_container.get_child(0).queue_free()
	grid_panel.show()
	grid_panel.name = "GridPanel"
	the_grid_panel_offset = grid_panel.size / 2
	for i in range(_context["inventory_num"]):
		grid_container.add_child(grid_panel)
		grid_panel = grid_panel.duplicate()
	grid_panel.queue_free()
	
	for inventory: Item in _context["inventory"]:
		var inventory_button = inventory_button_scene.instantiate()
		inventory_button.item_fullinfo = inventory.duplicate()
		inventory_button.item_texture = inventory.item_texture
		inventory_button.item_tilesize = inventory.item_tilesize
		inventory_button.initialize()
		
		
