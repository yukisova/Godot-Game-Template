## @editing: Sora [br]
## @describe: 背包系统扩展
class_name InventoryExtension
extends StatusExtension

signal inventory_added(new_item: Item, target_index: int)
signal inventory_removed(item_origin_index: int)

@export_group("背包信息","inventory_")
@export var inventory_array: Array[Item] ## 当前背包所包含的物品
@export_range(1, 25, 1, "or_greater") var inventory_pack_num: int ## 背包的总容量
@export var inventory_weight_num: float ## 背包的总承重

var current_pack_num: int ## 当前背包的容量
var current_weight_num: float ## 当前的承重

func _enter_tree() -> void:
	extention_type = ExtensionType.背包

func _initialize():
	
	inventory_array.resize(inventory_pack_num)
	

func _effect():
	pass

func auto_add_inventory(target: Item):
	for i in range(inventory_pack_num):
		if inventory_array[i] == null:
			inventory_array[i] = target.duplicate()
			inventory_added.emit(inventory_array[i], i)
			return

func remove_inventory_at(target_index: int):
	if target_index > inventory_pack_num - 1:
		return
	inventory_array[target_index] = null
	inventory_removed.emit(target_index)

func remove_inventory(target: Item):
	var index = inventory_array.find(target)
	if index == -1:
		push_error("删除物品 %s 失败，确保该物品本身位于Inventory_Array中"%[target.item_name])
	inventory_array[index] = null
	inventory_removed.emit(index)

## 两个特定物品在重叠时，若条件允许可以进行合成
func test_merge_item():
	pass
