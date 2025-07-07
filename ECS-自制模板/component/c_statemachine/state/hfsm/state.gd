@tool
abstract class_name State
extends Node

signal state_transition(from: NodePath, _keyword: StringName)
signal transition_finished


const DefaultKeyword : StringName = "EVENT_FINISHED"

var parent_to_self: NodePath
var state_owner: Entity
@export var state_controllers: Array[StateController]

func _enter_tree() -> void:
	parent_to_self = get_parent().get_path_to(self)
	state_owner = owner as Entity

func _enter():
	pass

func _update(_delta: float) -> void:
	pass

func _fixed_update(_delta: float) -> void:
	pass

func _exit():
	pass
