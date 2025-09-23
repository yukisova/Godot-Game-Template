@tool
class_name CStatusList
extends IComponent

signal status_overred(type: SoraConstant.StatusEnum)

@export var basic_info: Dictionary[SoraConstant.StatusEnum, float]

class StatusInfo:
	signal status_overed(status_enum: SoraConstant.StatusEnum)
	signal status_changed(status: StatusInfo)
	
	var status_enum: SoraConstant.StatusEnum
	var max_value: float
	var value: float:
		get:
			return value
		set(_value):
			if (_value < 0):
				value = 0
				status_overed.emit(status_enum)
			elif (_value > max_value):
				value = max_value
			else:
				value = _value
			status_changed.emit(self)
	
	func _init(_status_enum: SoraConstant.StatusEnum, _value: float, _max_value: float) -> void:
		status_enum = _status_enum
		max_value = _max_value
		value = _value

class NumInfo:
	var status_enum: SoraConstant.StatusEnum
	var value: int

	func _init(_status_enum: SoraConstant.StatusEnum, _value: int) -> void:
		status_enum = _status_enum
		value = _value

var status_list: Dictionary[SoraConstant.StatusEnum, StatusInfo] = {}
var numinfo_list: Dictionary[SoraConstant.StatusEnum, NumInfo] = {}
var status_extension: Dictionary[StatusExtension.ExtensionType, StatusExtension] = {}

func _enter_tree() -> void:
	component_name = ComponentName.C_STATUS_LIST

func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)
	for extension in get_children():
		if extension is StatusExtension:
			extension.c_status = self
			status_extension[extension.extention_type] = extension
			extension._initialize()
	if !SLoadAndSave.current_saved:
		for key in basic_info.keys():
			_add_status(key, {
				"value": basic_info[key]
			})
	initialize_completed.emit()

func _update(_delta: float):
	for extension in status_extension.values():
		extension._effect()

func _add_status(key: int, dict: Dictionary):
	var value = dict["value"]
	@warning_ignore("integer_division")
	match (key / 100):
		0:
			status_list[key] = StatusInfo.new(key, value, dict.get("max_value", value))
			status_list[key].status_overed.connect(_on_status_overed)
		1:
			numinfo_list[key] = NumInfo.new(key, value)

func _on_status_overed(_status_enum: SoraConstant.StatusEnum):
	status_overred.emit(_status_enum)
	match _status_enum:
		SoraConstant.StatusEnum.Health:
			component_owner.queue_free.call_deferred()

func _save() -> Dictionary:
	var c_status_returned = {}
	
	var status_infos = {}
	for status: StatusInfo in status_list.values():
		var status_info = {
			status.status_enum:{
				"value" : status.value,
				"max_value": status.max_value
			}
		}
		status_infos.merge(status_info)
	c_status_returned.merge({
		"status_infos": status_infos
	})
	
	var num_infos = {}
	for num: NumInfo in numinfo_list.values():
		var num_info = {
			num.status_enum:{
				"value": num.value
			}
		}
		num_infos.merge(num_info)
	c_status_returned.merge({
		"num_infos": num_infos
	})
	
	var extension_infos = {}
	for extension: StatusExtension in status_extension.values():
		var extension_info = extension._save()
		extension_infos.merge(extension_info)
	c_status_returned.merge({
		"extension_infos": extension_infos
	})
	return {IComponent.ComponentName.C_STATUS_LIST: c_status_returned}

func _load(_dict: Dictionary):
	var status_infos = _dict["status_infos"]
	for key in status_infos.keys():
		_add_status(key, status_infos[key])
	
	var num_infos = _dict["num_infos"]
	for key in num_infos.keys():
		_add_status(key, num_infos[key])
	
	var extension_infos = _dict["extension_infos"]
	for key in extension_infos.keys():
		status_extension[key]._load(extension_infos[key])

func get_status_extension(extension_type: StatusExtension.ExtensionType) -> StatusExtension:
	return status_extension.get(extension_type)

