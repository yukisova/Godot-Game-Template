class_name DragableItem
extends TextureRect

# 物品数据
var binding_item: Item:
	set(v):
		binding_item = v
		texture = binding_item.item_texture
		item_size = binding_item.item_tilesize

# 物品属性
var item_size: Vector2i = Vector2i(1, 1)
var current_slot: GridInventorySlot = null
var origin_slot: GridInventorySlot = null
var is_rotated: bool = false

func _ready():
	# 设置初始大小
	custom_minimum_size = Vector2i(64, 64) * item_size
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
