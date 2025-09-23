class_name ContainerBlackboardData
extends Resource

@export var _name: StringName
@export var _value: Variant

func _init(name: StringName, value: Variant):
	_name = name
	_value = value

func get_data_name() -> StringName:
	return _name

func get_data_value() -> Variant:
	return _value