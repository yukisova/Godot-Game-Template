extends UIModel

signal equipment_node_changed(item_equipment: ItemEquipment)
signal attack_node_changed(item_weapon: ItemWeapon)

var equipment: EquipmentExtension
var inventory: InventoryExtension

func _on_equipment_node_changed(item_equipment: ItemEquipment):
	equipment_node_changed.emit(item_equipment)

func _on_attack_node_changed(item_weapon: ItemWeapon):
	attack_node_changed.emit(item_weapon)

func _initialize(_context: Dictionary):
	equipment = _context["equipment"]
	inventory = _context["inventory"]

	equipment.equipment_node_changed.connect(_on_equipment_node_changed)
	equipment.attack_node_changed.connect(_on_attack_node_changed)
