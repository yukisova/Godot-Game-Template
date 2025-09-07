## 实体状态组件 - 管理实体的各种状态和数值信息
## 分为StatusInfo（动态状态如血量）和NumInfo（基础数值如攻击力）
## 支持状态扩展系统、边界检查、变化事件和扩展管理
## [br][b]编辑者:[/b] Sora
@tool
class_name CStatusList
extends IComponent

## 状态超限信号
## [param type]: 触发超限的状态类型
signal status_overred(type: SoraConstant.StatusEnum)

## 初始状态信息配置
## 定义实体的基础状态数值
@export var basic_info: Dictionary[SoraConstant.StatusEnum, float]

## 状态信息类
## 管理动态状态值，具有边界检查和事件触发
class StatusInfo:
	## 状态超限信号
	## [param status_enum]: 触发超限的状态类型
	signal status_overed(status_enum: SoraConstant.StatusEnum)
	
	## 状态值变化信号
	## [param status]: 发生变化的状态信息对象
	signal status_changed(status: StatusInfo)
	
	## 状态类型标识
	var status_enum: SoraConstant.StatusEnum
	
	## 当前状态值，自动边界检查
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
	
	## 状态最大值
	var max_value: float
	
	## 创建新的状态信息对象
	## [param _status_enum]: 状态类型
	## [param _value]: 状态的初始值
	## [param _max_value]: 状态的最大值限制
	func _init(_status_enum: SoraConstant.StatusEnum, _value: float, _max_value: float) -> void:
		status_enum = _status_enum
		max_value = _max_value
		value = _value

## 数值信息类
## 管理相对稳定的数值属性，无边界检查
class NumInfo:
	## 数值类型标识
	var status_enum: SoraConstant.StatusEnum
	
	## 数值大小
	var value: int
	
	## 创建新的数值信息对象
	## [param _status_enum]: 数值类型
	## [param _value]: 数值的大小
	func _init(_status_enum: SoraConstant.StatusEnum, _value: int) -> void:
		status_enum = _status_enum
		value = _value

## 状态信息字典
## 存储所有StatusInfo类型的状态，如血量、耐力等需要频繁变动的状态信息
var status_list: Dictionary[SoraConstant.StatusEnum, StatusInfo] = {}

## 数值信息字典
## 存储所有NumInfo类型的数值，如攻击力、防御力等基础数值信息
var numinfo_list: Dictionary[SoraConstant.StatusEnum, NumInfo] = {}

## 状态扩展字典
## 存储各种状态扩展效果，如Buff、Debuff等临时状态修改器
var status_extension: Dictionary[StatusExtension.ExtensionType, StatusExtension] = {}

func _enter_tree() -> void:
	component_name = ComponentName.C_STATUS_LIST

## 收集状态扩展并创建状态对象
## [param _owner]: 拥有此组件的实体
## [param _load_data]: 可选的加载数据
func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)
	
	# 收集并初始化所有状态扩展
	for extension in get_children():
		if extension is StatusExtension:
			extension.c_status = self
			status_extension[extension.extention_type] = extension
			extension._initialize()
	
	if !SLoadAndSave.current_saved:
	# 根据基础信息创建状态对象
		for key in basic_info.keys():
			_add_status(key, {
				"value": basic_info[key]
			})
	
	initialize_complete.emit()

func _add_status(key: int, dict: Dictionary):
	var value = dict["value"]
	@warning_ignore("integer_division")
	match (key / 100):
		0:
			status_list[key] = StatusInfo.new(key, value, dict.get("max_value", value))
			status_list[key].status_overed.connect(_on_status_overed)
		1:
			numinfo_list[key] = NumInfo.new(key, value)

func get_status_extension(extension_type: StatusExtension.ExtensionType) -> StatusExtension:
	return status_extension.get(extension_type)

## 每帧调用所有状态扩展的效果方法
## [param _delta]: 帧时间间隔
func _update(_delta: float):
	for extension in status_extension.values():
		extension._effect()

## 状态值达到临界值时的回调处理
## [param _status_enum]: 触发超限的状态类型
func _on_status_overed(_status_enum: SoraConstant.StatusEnum):
	status_overred.emit(_status_enum)
	match _status_enum:
		SoraConstant.StatusEnum.Health: # 生命值归零时销毁实体
			print("%s因生命值归零被销毁" % [component_owner.name])
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
