class_name C_Marker
extends IComponent

func _enter_tree() -> void:
	component_name = ComponentName.c_marker

func _initialize(_owner: Entity):
	super(_owner)
