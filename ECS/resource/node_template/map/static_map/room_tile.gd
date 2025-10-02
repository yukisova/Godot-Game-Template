@tool
class_name Room
extends Node2D

## 位于本层的实体
@export var belongs_entities: Array[IEntity]
@export var is_room_visible: bool:
	set(v):
		is_room_visible = v
		if is_room_visible:
			factor_modulate = Color.WHITE
		else:
			factor_modulate = Color.TRANSPARENT
var tween: Tween 


var factor_modulate: Color = Color.WHITE:
	set(v): 
		factor_modulate = v
		if is_node_ready():
			tween = get_tree().create_tween()
			tween.tween_property(self, "modulate", factor_modulate, 0.5)
			for i in belongs_entities:
				tween.set_parallel(true).tween_property(i, "modulate", factor_modulate, 0.5)
		else:
			modulate = factor_modulate
			for i in belongs_entities:
				i.modulate = factor_modulate
