class_name InventoryExtension
extends StatusExtension

signal inventory_added(new_item: Item, target_index: int)
signal inventory_removed(item_origin_index: int)
signal inventory_full
signal weight_exceeded(current_weight: float, max_weight: float)

@export_group("背包信息", "inventory_")
@export var inventory_array_consumable: Array[ItemConsumable]
@export var inventory_array_document: Array[ItemDocument]
@export var inventory_array_weapon: Dictionary[String, ItemWeapon]
@export var inventory_array_equipment: Dictionary[String, ItemEquipment]

@export var inventory_array_left_quick: Array[String]:
	set(v):
		v.resize(2)
		for i in range(v.size()):
			var value = v[i]
			if value in inventory_array_right_quick:
				push_error("背包系统: 左手快捷切换索引与右手快捷切换索引重复 -> " + value)
				v[i] = ""
		inventory_array_left_quick = v
@export var inventory_array_right_quick: Array[String]:
	set(v):
		v.resize(2)
		for i in range(v.size()):
			var value = v[i]
			if value in inventory_array_left_quick:
				push_error("背包系统: 右手快捷切换索引与左手快捷切换索引重复 -> " + value)
				v[i] = ""

		inventory_array_right_quick = v

@export_range(1, 25, 1, "or_greater") var inventory_pack_num: int = 20
@export_range(1, 8, 1, "or_greater") var inventory_pack_col: int = 4

@export var inventory_weight_num: float = 100.0

var current_pack_num: int = 0
var current_weight_num: float = 0.0

func _enter_tree() -> void:
	extention_type = ExtensionType.INVENTORY

func _initialize():
	inventory_array_consumable.resize(inventory_pack_num)
	_update_inventory_stats()

func _effect():
	pass

func auto_add_inventory(target: Item) -> bool:
	if target is ItemWeapon:
		inventory_array_weapon[target.item_nick_name] = target
		return true
	elif target is ItemEquipment:
		inventory_array_equipment[target.item_nick_name] = target
		return true
	elif target is ItemConsumable:
		#if current_weight_num + target.get_weight() > inventory_weight_num:
			#weight_exceeded.emit(current_weight_num + target.get_weight(), inventory_weight_num)
			#return false
		# 查找空位
		for i in range(inventory_pack_num):
			if inventory_array_consumable[i] == null:
				inventory_array_consumable[i] = target.duplicate()
				current_pack_num += 1
				current_weight_num += target.get_weight()
				inventory_added.emit(inventory_array_consumable[i], i)
				return true

	elif target is ItemDocument:
		inventory_array_document.append(target)
		return true
	
	# 背包已满
	inventory_full.emit()
	return false

func add_inventory_at(target: Item, index: int) -> bool:
	if index < 0 or index >= inventory_pack_num:
		push_error("背包系统: 索引超出范围 -> " + str(index))
		return false
	
	if inventory_array_consumable[index] != null:
		push_warning("背包系统: 目标位置已有物品 -> " + str(index))
		return false
	
	# 检查重量限制
	if current_weight_num + target.get_weight() > inventory_weight_num:
		weight_exceeded.emit(current_weight_num + target.get_weight(), inventory_weight_num)
		return false
	
	inventory_array_consumable[index] = target.duplicate()
	current_pack_num += 1
	current_weight_num += target.get_weight()
	inventory_added.emit(inventory_array_consumable[index], index)
	return true

func remove_inventory_at(target_index: int) -> Item:
	if target_index < 0 or target_index >= inventory_pack_num:
		push_error("背包系统: 索引超出范围 -> " + str(target_index))
		return null
	
	var removed_item = inventory_array_consumable[target_index]
	if removed_item != null:
		inventory_array_consumable[target_index] = null
		current_pack_num -= 1
		current_weight_num -= removed_item.get_weight()
		inventory_removed.emit(target_index)
	
	return removed_item

func try_remove_inventory(target: Item) -> bool:
	var index = inventory_array_consumable.find(target)
	if index == -1:
		push_error("背包系统: 删除物品失败，物品不在背包中 -> " + target.item_name)
		return false
	
	remove_inventory_at(index)
	return true

func get_inventory_at(index: int) -> Item:
	if index < 0 or index >= inventory_pack_num:
		return null
	return inventory_array_consumable[index]

func find_consumable_by_nick_name(nick_name: String) -> ItemConsumable:
	var index = inventory_array_consumable.find_custom(func(item: ItemConsumable) -> bool: return item.item_nick_name == nick_name)
	if index == -1:
		return null
	return inventory_array_consumable[index]

func remove_consumable_by_nick_name(nick_name: String) -> bool:
	var index = inventory_array_consumable.find_custom(func(item: ItemConsumable) -> bool: return item.item_nick_name == nick_name)
	if index == -1:
		push_error("背包系统: 删除物品失败，物品不在背包中 -> " + nick_name)
		return false
	remove_inventory_at(index)
	return true
	
func get_empty_slots() -> int:
	return inventory_pack_num - current_pack_num

func _update_inventory_stats():
	current_pack_num = 0
	current_weight_num = 0.0
	
	for item in inventory_array_consumable:
		if item != null:
			current_pack_num += 1
			current_weight_num += item.get_weight()

#region
func _save() -> Dictionary:
	return {
		extention_type:{
			"inventory_array_consumable": inventory_array_consumable.duplicate_deep(),
			"inventory_pack_col": inventory_pack_col,
			"inventory_pack_num": inventory_pack_num
		}
	}

func _load(_data: Dictionary):
	var _inventory_array: Array = _data["inventory_array_consumable"]
	for item: Item in _inventory_array:
		if item != null:
			auto_add_inventory(item)
	inventory_pack_col = _data["inventory_pack_col"] as int
	inventory_pack_num = _data["inventory_pack_num"] as int
	
#endregion
