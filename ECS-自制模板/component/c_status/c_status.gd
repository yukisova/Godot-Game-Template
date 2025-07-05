## 状态组件, 目标是
@tool
class_name C_Status
extends IComponent

signal status_overred(type: SoraConstant.StatusEnum)


@export_subgroup("初始状态")
@export var basic_info: Dictionary[SoraConstant.StatusEnum, float]

class StatusInfo:
	signal status_overed(status_enum: SoraConstant.StatusEnum)
	signal status_changed
	
	var status_enum: SoraConstant.StatusEnum
	var value: float:
		get:
			return value
		set(_value):
			if (value < 0):
				value = 0
				status_overed.emit(status_enum)
			elif (value > max_value):
				value = max_value
			else:
				value = _value
			status_changed.emit()
			
	var max_value: float
	
	func _init(_status_enum: SoraConstant.StatusEnum, _value: float, _max_value: float) -> void:
		status_enum = _status_enum
		max_value = _max_value
		value = _value

class BuffInfo:
	signal status_overed(status_enum: SoraConstant.StatusEnum)
	
	func _init(_status_enum: SoraConstant.StatusEnum) -> void:
		
		pass

class NumInfo:
	var status_enum: SoraConstant.StatusEnum
	var value: int
	func _init(_status_enum: SoraConstant.StatusEnum, _value: int) -> void:
		status_enum = _status_enum
		value = _value

var status_list: Dictionary[SoraConstant.StatusEnum, StatusInfo] = {} ## 血量，耐力等需要频繁变动的状态信息
var buff_list: Dictionary[SoraConstant.StatusEnum, BuffInfo] = {} ## 睡眠，晕眩等Buff信息
var numinfo_list: Dictionary[SoraConstant.StatusEnum, NumInfo] = {} ## 攻击力，防御力等基础数值信息

var status_extension: Dictionary[String, StatusExtension] = {} ## 

func _initialize(_owner: Entity):
	super._initialize(_owner)
	for extension in get_children():
		if extension is StatusExtension:
			status_extension[extension.name] = extension
	for key in basic_info.keys():
		var info = basic_info[key]
		match (key / 100):
			0: 
				status_list[key] = StatusInfo.new(key, info, info)
				status_list[key].status_overed.connect(_on_status_overed)
			1:
				pass
			2:
				numinfo_list[key] = NumInfo.new(key, info)
				pass
			

func _on_status_overed(_status_enum: SoraConstant.StatusEnum):
	status_overred.emit(_status_enum)
	match _status_enum:
		SoraConstant.StatusEnum.Health:
			
			print(
				"%s被销毁" %
				[component_owner.name]
			)
			
			component_owner.queue_free.call_deferred()
