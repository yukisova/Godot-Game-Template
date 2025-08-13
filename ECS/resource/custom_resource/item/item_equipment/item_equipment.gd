## 装备物品类
class_name ItemEquipment
extends Item

@export var equipment_node: PackedScene ## 武器攻击所使用的节点，会搭载至c_status下的equipment节点下
var is_equipped: bool

func _equip(...args):
	var c_status = args[0] as CStatus
	var equipment: EquipmentExtension = c_status.status_extension[StatusExtension.ExtensionType.EQUIPMENT]
	equipment.equipment_node_changed.emit(self)

func _unequip(...args):
	var c_status = args[0] as CStatus
	var equipment: EquipmentExtension = c_status.status_extension[StatusExtension.ExtensionType.EQUIPMENT]
	equipment.equipment_node_changed.emit(null)

func get_func_callable() -> Array[Dictionary]:
	var result = super()
	if not is_equipped:
		result.push_front({
			STR_NAME:"equip",
			STR_FUNC:_equip,
			STR_TEXT:"装备"
		})
	else:
		result.push_front({
			STR_NAME:"unequip",
			STR_FUNC:_unequip,
			STR_TEXT:"卸下"
		})
	return result
