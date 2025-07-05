abstract class_name Buff
extends RefCounted

signal buff_overed(buff: Buff)

var current_time: float = 0
var continue_time: float
var buff_owner : Entity

func _init(_continue_time: float, _owner: Entity) -> void:
	continue_time = _continue_time
	current_time = 0
	buff_owner = _owner
	
func _effect():
	pass

func _uneffect():
	pass
