@tool
class_name InteractionRecord
extends Resource

enum InteractType{ Null= -1 , BodyEntered = 0, AreaEntered, RayCasted }

@export var is_passive: bool
@export var interact_type: InteractType:
	set(v):
		interact_type = v
		notify_property_list_changed()
@export_node_path("PassiveInteraction") var interaction: NodePath
@export_node_path("InteractBox") var interact_box: NodePath

func _validate_property(property: Dictionary) -> void:
	if interact_type == InteractType.RayCasted:
		if property.name == "interact_box":
			property.usage = PROPERTY_USAGE_NO_EDITOR
