## [br][b]编辑者:[/b] Sora
class_name ListDocument
extends MarginContainer

signal document_selected(document: ItemDocument)

@export var button_prototype: Button
@export var document_list_container: VBoxContainer

func _initialize_info(_context: Dictionary):
	var inventory: InventoryExtension = _context["inventory"]
	var documents: Array[ItemDocument] = inventory.inventory_array_document

	for document in documents:
		var new_button: Button = button_prototype.duplicate()
		document_list_container.add_child(new_button)
		new_button.text = document.item_name
		new_button.args = [document]
		new_button.pressed.connect(_on_button_selected.bind(document))

func _on_button_selected(document: ItemDocument):
	document_selected.emit(document)
