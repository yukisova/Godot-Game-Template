extends UIView

@export var grid_inventory: GridInventory
@export var panel_button_weapon_prototype: PanelButtonWeapon

@export var item_weapon_list: VBoxContainer
@export var list_document: ListDocument

@export var document_title: Label
@export var document_info: RichTextLabel

@export var tab_container: TabContainer

func _initialize(_context: Dictionary):
	var inventory: InventoryExtension = _context["inventory"]
	var equipment: EquipmentExtension = _context["equipment"]
	var status: CStatusList = inventory.c_status

	grid_inventory.c_status_list = status
	grid_inventory.grid_num = inventory.inventory_pack_num
	grid_inventory.col_num = inventory.inventory_pack_col

	for i in inventory.inventory_array_weapon.values():
		if i != null and (i is ItemWeapon or i is ItemEquipment):
			# 1. 根据按钮的原型，复制并绑定按钮信息
			var new_button: PanelButtonWeapon = panel_button_weapon_prototype.duplicate()
			item_weapon_list.add_child(new_button)
			new_button.binding_item = i
			new_button.target_c_status = status
			new_button.button.pressed.connect(new_button.button_func.bind({}))
	
	list_document._initialize_info(_context)
	grid_inventory._initialize_info(_context)
	
	list_document.document_selected.connect(_on_document_selected)

func _on_equipment_node_changed(item_equipment: ItemEquipment):
	pass

func _on_attack_node_changed(item_weapon: ItemWeapon):
	grid_inventory.equipment_control = item_weapon.equipment_control.instantiate()
	grid_inventory.equipment_control.binding_equipment = item_weapon
	grid_inventory.equipment_control._initialize()

func _on_document_selected(document: ItemDocument):
	document_title.text = document.item_name
	document_info.text = document.document_content

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_right"):
		var current_tab = tab_container.current_tab
		current_tab = (current_tab+1) % tab_container.get_child_count()
		tab_container.current_tab = current_tab
