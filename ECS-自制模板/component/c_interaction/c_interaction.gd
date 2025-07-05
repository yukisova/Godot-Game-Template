@tool
class_name C_Interaction
extends IComponent

signal interact_activated(compoent: IComponent)
signal interact_deactivated(component: IComponent)

@export_subgroup("依赖")
@export var interact_object: CollisionObject2D
@export var interaction: Interaction


func _enter_tree() -> void:
	component_name = ComponentName.c_interaction

func _initialize(_owner: Entity):
	super._initialize(_owner)
	
	interact_activated.connect(interaction._on_interact_activated)
	interact_deactivated.connect(interaction._on_interact_deactivated)
	
	if (interact_object == null):
		var final = component_body
		if final is Area2D:
			final.body_entered.connect(
				func(_body:Node2D):
					if _body.is_in_group("player"):
						interact_activated.emit(self)
			)
			final.body_exited.connect(
				func(_body:Node2D):
					if _body.is_in_group("player"):
						interact_deactivated.emit(self)
			)
	else:
		interact_object.call("_setup")
