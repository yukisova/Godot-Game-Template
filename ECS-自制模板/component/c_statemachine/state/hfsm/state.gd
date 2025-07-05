@tool
abstract class_name State
extends Node

signal state_transition(from: NodePath, _keyword: StringName)
signal transition_finished


const DefaultKeyword : StringName = "EVENT_FINISHED"

var parent_to_self: NodePath 

#@export var enable_value_inject: bool:
	#set(v):
		#notify_property_list_changed()
		#enable_value_inject = v
#@export var inject_values: Array 
#
#func _validate_property(property: Dictionary) -> void:
	#if enable_value_inject:
		#if property.name == "inject_values":
			#property.usage = PROPERTY_USAGE_NO_EDITOR


func _enter_tree() -> void:
	parent_to_self = get_parent().get_path_to(self)

func _enter():
	pass

func _update(_delta: float) -> void:
	pass

func _fixed_update(_delta: float) -> void:
	pass

func _exit():
	pass
