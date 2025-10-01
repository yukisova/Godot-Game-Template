@tool
extends ObjectEntity

func _setup() -> void:
	main_control = StaticBody2D.new()
	main_control.collision_layer = Main.PhysicsLayer.Wall | Main.PhysicsLayer.Interactable
	add_child(main_control)
	
	for i in get_children():
		if i is CollisionShape2D or i is CollisionPolygon2D:
			i.reparent(main_control)
			
	_initialize()
	
func _initialize() -> void:
	initialize_complete.emit()
