## 背包系统扩展 - 提供物品存储和管理功能
## 完整的背包管理系统，支持容量管理、重量限制、自动整理
## 提供物品操作、事件通知和与Item系统的深度集成
## [br][b]编辑者:[/b] Sora
class_name InventoryExtension
extends StatusExtension

## 物品添加信号
## [param new_item]: 新添加的物品
## [param target_index]: 物品索引位置
signal inventory_added(new_item: Item, target_index: int)

## 物品移除信号
## [param item_origin_index]: 被移除物品的索引位置
signal inventory_removed(item_origin_index: int)

## 背包容量已满信号
signal inventory_full

## 背包重量超限信号
## [param current_weight]: 当前重量
## [param max_weight]: 最大承重
signal weight_exceeded(current_weight: float, max_weight: float)

@export_group("背包信息", "inventory_")
## 背包物品数组
## 存储所有物品，null表示空槽位
@export var inventory_array: Array[Item]

## 存储武器与装备的物品数组
@export var inventory_array_weapon: Dictionary[String, Item]

## 左手快捷切换索引，如果值为""则表示空手
@export var inventory_array_left_quick: Array[String]:
	set(v):
		v.resize(2) ## 左手快捷切换索引
		for i in range(v.size()):
			var value = v[i]
			if value in inventory_array_right_quick:
				push_error("背包系统: 左手快捷切换索引与右手快捷切换索引重复 -> " + value)
				v[i] = ""
		inventory_array_left_quick = v

@export var inventory_array_right_quick: Array[String]:
	set(v):
		v.resize(2) ## 右手快捷切换索引
		for i in range(v.size()):
			var value = v[i]
			if value in inventory_array_left_quick:
				push_error("背包系统: 右手快捷切换索引与左手快捷切换索引重复 -> " + value)
				v[i] = ""

		inventory_array_right_quick = v


## 背包总容量
@export_range(1, 25, 1, "or_greater") var inventory_pack_num: int = 20

## 背包列数
## 
## 背包UI显示的列数，用于网格布局。
@export_range(1, 8, 1, "or_greater") var inventory_pack_col: int = 4

## 背包总承重
## 
## 背包可以承受的最大重量限制。
@export var inventory_weight_num: float = 100.0

## 当前背包使用容量
## 
## 统计当前背包中非空槽位的数量。
var current_pack_num: int = 0

## 当前背包重量
## 
## 统计当前背包中所有物品的总重量。
var current_weight_num: float = 0.0

## 节点初始化
## 设置扩展类型为背包
func _enter_tree() -> void:
	extention_type = ExtensionType.INVENTORY

## 扩展初始化
## 调整背包数组大小并更新统计信息
func _initialize():
	inventory_array.resize(inventory_pack_num)
	_update_inventory_stats()

## 扩展效果执行
## 背包系统通常不需要每帧更新，保持空实现
func _effect():
	# 背包系统主要响应事件，不需要每帧更新
	pass

## 自动寻找空位放置物品
## [param target]: 要添加的物品
func auto_add_inventory(target: Item) -> bool:
	if target is ItemWeapon or target is ItemEquipment:
		# FIXME 武器物品需要特殊处理，并不用加入网格背包
		inventory_array_weapon[target.item_nick_name] = target
		return true
	elif target is ItemBullet or target is ItemConsumable:
		# 检查重量限制
		if current_weight_num + target.get_weight() > inventory_weight_num:
			weight_exceeded.emit(current_weight_num + target.get_weight(), inventory_weight_num)
			return false
		
		# 查找空位
		for i in range(inventory_pack_num):
			if inventory_array[i] == null:
				inventory_array[i] = target.duplicate()
				current_pack_num += 1
				current_weight_num += target.get_weight()
				inventory_added.emit(inventory_array[i], i)
				return true
	elif target is ItemDocument:
		# FIXME 文档物品需要特殊处理，加入另一个文档背包
		pass
	
	# 背包已满
	inventory_full.emit()
	return false

## 在指定位置添加物品
## 
## [param target]: 要添加的物品，类型为 [Item]
## [param index]: 目标索引位置
## [br][br][b]返回:[/b] [bool] 是否成功添加
func add_inventory_at(target: Item, index: int) -> bool:
	if index < 0 or index >= inventory_pack_num:
		push_error("背包系统: 索引超出范围 -> " + str(index))
		return false
	
	if inventory_array[index] != null:
		push_warning("背包系统: 目标位置已有物品 -> " + str(index))
		return false
	
	# 检查重量限制
	if current_weight_num + target.get_weight() > inventory_weight_num:
		weight_exceeded.emit(current_weight_num + target.get_weight(), inventory_weight_num)
		return false
	
	inventory_array[index] = target.duplicate()
	current_pack_num += 1
	current_weight_num += target.get_weight()
	inventory_added.emit(inventory_array[index], index)
	return true

## 移除指定位置的物品
## 
## [param target_index]: 要移除物品的索引位置
## [br][br][b]返回:[/b] [Item] 被移除的物品，如果位置为空则返回null
func remove_inventory_at(target_index: int) -> Item:
	if target_index < 0 or target_index >= inventory_pack_num:
		push_error("背包系统: 索引超出范围 -> " + str(target_index))
		return null
	
	var removed_item = inventory_array[target_index]
	if removed_item != null:
		inventory_array[target_index] = null
		current_pack_num -= 1
		current_weight_num -= removed_item.get_weight()
		inventory_removed.emit(target_index)
	
	return removed_item

## 移除指定物品
## @param target: 要移除的物品实例
## @return: 是否成功移除
func try_remove_inventory(target: Item) -> bool:
	var index = inventory_array.find(target)
	if index == -1:
		push_error("背包系统: 删除物品失败，物品不在背包中 -> " + target.item_name)
		return false
	
	remove_inventory_at(index)
	return true

## 获取指定位置的物品
## @param index: 索引位置
## @return: 物品实例，如果位置为空或索引无效则返回null
func get_inventory_at(index: int) -> Item:
	if index < 0 or index >= inventory_pack_num:
		return null
	return inventory_array[index]

## 查找物品在背包中的位置
## @param target: 要查找的物品
## @return: 物品索引，如果未找到返回-1
func find_inventory(target: Item) -> int:
	return inventory_array.find(target)

## 检查背包是否已满
## @return: 是否已满
func is_inventory_full() -> bool:
	return current_pack_num >= inventory_pack_num

## 检查是否超重
## @return: 是否超重
func is_overweight() -> bool:
	return current_weight_num > inventory_weight_num

## 获取空位数量
## @return: 空位数量
func get_empty_slots() -> int:
	return inventory_pack_num - current_pack_num

## 清空背包
func clear_inventory():
	for i in range(inventory_pack_num):
		if inventory_array[i] != null:
			remove_inventory_at(i)

## 物品合成测试
## 检查两个相邻物品是否可以合成，如果可以则执行合成
## TODO: 实现具体的物品合成逻辑
func test_merge_item():
	# 待实现：检查可叠加物品并进行合并
	pass

## 更新背包统计信息
## 重新计算当前容量和重量
func _update_inventory_stats():
	current_pack_num = 0
	current_weight_num = 0.0
	
	for item in inventory_array:
		if item != null:
			current_pack_num += 1
			current_weight_num += item.get_weight()

#region
func _save() -> Dictionary:
	return {
		extention_type:{
			"inventory_array": inventory_array.duplicate_deep(),
			"inventory_pack_col": inventory_pack_col,
			"inventory_pack_num": inventory_pack_num
		}
	}

func _load(_data: Dictionary):
	var _inventory_array: Array = _data["inventory_array"]
	for item: Item in _inventory_array:
		if item != null:
			auto_add_inventory(item)
	inventory_pack_col = _data["inventory_pack_col"] as int
	inventory_pack_num = _data["inventory_pack_num"] as int
	
#endregion
