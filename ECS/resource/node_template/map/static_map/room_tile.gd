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
 
var factor_modulate: Color = Color.WHITE:
	set(v):
		factor_modulate = v
		for i in belongs_entities:
			i.modulate = factor_modulate
		modulate = factor_modulate
