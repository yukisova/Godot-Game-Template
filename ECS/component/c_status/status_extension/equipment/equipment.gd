## @editing: Sora [br]
## @describe: 装备系统扩展
## 装备系统下搭载着可以实现装备效果的节点，目前的主要应用为远程武器
class_name EquipmentExtension
extends StatusExtension
## 
signal attack_node_changed(item_weapon: ItemWeapon)
signal equipment_node_changed(item_equipment: Item)

var current_weapon: ItemWeapon:
	set(v):
		if current_weapon:
			current_weapon.is_equipped = false
		current_weapon = v
		if current_weapon:
			current_weapon.is_equipped = true

var current_attack_node: WeaponAttackNode: ## 当前装备的攻击节点
	set(v):
		if current_attack_node:
			current_attack_node.queue_free()
		current_attack_node = v

var current_equipment: ItemEquipment:
	set(v):
		if current_equipment:
			current_equipment.is_equipped = false
		current_equipment = v
		if current_equipment:
			current_equipment.is_equipped = true

var current_equipment_node: Node2D: ## 当前装备的装备节点
	set(v):
		if current_equipment_node:
			current_equipment_node.queue_free()
		current_equipment_node = v

## 节点初始化
## 设置扩展类型为背包
func _enter_tree() -> void:
	extention_type = ExtensionType.EQUIPMENT

func _initialize():
	attack_node_changed.connect(_on_attack_node_changed)
	equipment_node_changed.connect(_on_equipment_node_changed)

func _effect():
	pass

func _on_attack_node_changed(item_weapon: ItemWeapon):
	if item_weapon:
		current_weapon = item_weapon
		current_attack_node = item_weapon.weapon_node.instantiate()
		current_attack_node.c_status = c_status
		add_child(current_attack_node)
	else:
		current_weapon = null
		current_attack_node = null
	
func _on_equipment_node_changed(item_equipment: ItemEquipment):
	if item_equipment:
		current_equipment = item_equipment
		current_equipment_node = item_equipment.equipment_node.instantiate()
		current_equipment_node.c_status = c_status
		add_child(current_equipment_node)
	else:
		current_equipment = null
		current_equipment_node = null
