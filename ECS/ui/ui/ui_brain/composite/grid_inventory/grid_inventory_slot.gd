## @describe: 用于实现类生化四的背包的SlotPanelContainer

class_name GridInventorySlot
extends PanelContainer

var current_index: Vector2i = Vector2i(-1, -1)
var linkage_dragable: DragableItem = null

func _ready():
	custom_minimum_size = Vector2(64, 64)
	
	# 添加长按检测
	var timer = Timer.new()
	timer.wait_time = 0.01
	timer.one_shot = false
	add_child(timer)
	timer.start()
