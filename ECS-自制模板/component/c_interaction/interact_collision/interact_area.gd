extends Area2D

@export var c_interaction: C_Interaction


## 避免问题
func _setup() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D):
	if (body.is_in_group(&"player")):
		c_interaction.interact_activated.emit(c_interaction)
	
func _on_body_exited(body: Node2D):
	if (body.is_in_group(&"player")):
		c_interaction.interact_deactivated.emit(c_interaction)
