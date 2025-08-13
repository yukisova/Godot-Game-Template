## 武器物品类
## 包含武器的使用子弹名称，使用的攻击模式逻辑，在由玩家获得武器之后，可以进行进一步的
class_name ItemWeapon
extends Item

@export var weapon_node: PackedScene ## 武器攻击所使用的节点，会搭载至c_status下的equipment节点下
var is_equipped: bool

func _equip(...args):
	var c_status = args[0] as CStatus
	var equipment: EquipmentExtension = c_status.status_extension[StatusExtension.ExtensionType.EQUIPMENT]
	equipment.attack_node_changed.emit(self)

func _unequip(...args):
	var c_status = args[0] as CStatus
	var equipment: EquipmentExtension = c_status.status_extension[StatusExtension.ExtensionType.EQUIPMENT]
	equipment.attack_node_changed.emit(null)

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
