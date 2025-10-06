extends UIView

@export var grid_inventory: GridInventory
@export var panel_button_weapon_prototype: PanelButtonWeapon

@export var item_weapon_list: VBoxContainer
@export var list_document: ListDocument

@export var document_title: Label
@export var document_info: RichTextLabel

@export var tab_container: TabContainer

@onready var document_check: HBoxContainer = %DocumentCheck

var current_document_vision: DocumentVision = null:
	set(v):
		current_document_vision = v
		if current_document_vision != null:
			document_title.text = current_document_vision.title
			document_info.text = current_document_vision.get_current_con()
		else:
			document_title.text = ""
			document_info.text = ""
		if current_document_vision == null or current_document_vision.content.size() <= 1:
			document_check.visible = false
		else:
			document_check.visible = true

func _initialize(_context: Dictionary):
	var inventory: InventoryExtension = _context["inventory"]
	var equipment: EquipmentExtension = _context["equipment"]
	var status: CStatusList = inventory.c_status

	grid_inventory.c_status_list = status
	grid_inventory.grid_num = inventory.inventory_pack_num
	grid_inventory.col_num = inventory.inventory_pack_col

	for i in inventory.inventory_array_weapon.values():
		if i != null and (i is ItemWeapon):
			# 1. 根据按钮的原型，复制并绑定按钮信息
			var new_button: PanelButtonWeapon = panel_button_weapon_prototype.duplicate()
			item_weapon_list.add_child(new_button)
			new_button.binding_item = i
			new_button.target_c_status = status
			new_button.button.pressed.connect(new_button.button_func.bind({}))
	for i in inventory.inventory_array_equipment.values():
		if i != null and (i is ItemEquipment):
			# 1. 根据按钮的原型，复制并绑定按钮信息
			var new_button: PanelButtonWeapon = panel_button_weapon_prototype.duplicate()
			item_weapon_list.add_child(new_button)
			new_button.binding_item = i
			new_button.target_c_status = status
			new_button.button.pressed.connect(new_button.button_func.bind({}))
	
	list_document._initialize_info(_context)
	grid_inventory._initialize_info(_context)
	
	list_document.document_selected.connect(_on_document_selected)
	document_check.get_node("LastPage").pressed.connect(_on_last_page_pressed)
	document_check.get_node("NextPage").pressed.connect(_on_next_page_pressed)

func _on_equipment_node_changed(item_equipment: ItemEquipment):
	pass

func _on_attack_node_changed(item_weapon: ItemWeapon):
	grid_inventory.equipment_control = item_weapon.equipment_control.instantiate()
	grid_inventory.equipment_control.binding_equipment = item_weapon
	grid_inventory.equipment_control._initialize()

class DocumentVision:
	var title: String
	var content: PackedStringArray
	var current_index: int = 0:
		set(v):
			current_index = v
			current_index = clamp(current_index, 0, content.size()-1)

	func get_current_con() -> String:
		if content.size() == 0:
			return ""
		return content[current_index]

	func _init(_document: ItemDocument):
		title = _document.item_name
		content = _document.document_content
		current_index = 0


func _on_document_selected(document: ItemDocument):
	current_document_vision = DocumentVision.new(document)
	
func _on_next_page_pressed():
	if current_document_vision != null:
		current_document_vision.current_index += 1
		document_info.text = current_document_vision.get_current_con()

func _on_last_page_pressed():
	if current_document_vision != null:
		current_document_vision.current_index -= 1
		document_info.text = current_document_vision.get_current_con()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_right"):
		var current_tab = tab_container.current_tab
		current_tab = (current_tab+1) % tab_container.get_child_count()
		tab_container.current_tab = current_tab
