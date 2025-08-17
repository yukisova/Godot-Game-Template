## 实体状态组件 - 管理实体的各种状态和数值信息
##
## 该组件负责管理实体的所有状态相关数据，支持扩展系统。
## 分为两种主要状态类型：
##
## 1. [class StatusInfo]（状态信息）：
##    - 如血量、魔力等需要时刻监控的动态信息
##    - 具有最大值限制和临界值触发机制
##    - 当值达到边界时会触发相应信号
##
## 2. [class NumInfo]（数值信息）：
##    - 如攻击力、防御力等影响游戏体验的基础数值
##    - 相对稳定，不会频繁变化
##    - 主要用作属性修饰和计算基础
##
## 功能特性：
## - 支持状态扩展系统（如Buff/Debuff）
## - 自动处理状态边界检查
## - 状态变化事件系统
## - 状态归零时的特殊处理（如死亡）
##
## [br][b]编辑者:[/b] Sora
@tool
class_name CStatus
extends IComponent

## 状态超限信号
## 
## 当 [class StatusInfo] 类型的状态值达到临界值（如生命值归零）时触发。
## [param type]: 触发超限的状态类型，参见 [enum SoraConstant.StatusEnum]
signal status_overred(type: SoraConstant.StatusEnum)

## 初始状态信息配置
## 
## 定义实体的基础状态数值，未明确设置的状态默认为零。
## 键为 [enum SoraConstant.StatusEnum]，值为对应的初始数值。
@export var basic_info: Dictionary[SoraConstant.StatusEnum, float]

## 状态信息类
## 
## 用于管理动态变化的状态值，如生命值、魔力值等。
## 具有自动边界检查和事件触发功能。
class StatusInfo:
	## 状态超限信号
	## 
	## 当状态值降至0或超过最大值时触发。
	## [param status_enum]: 触发超限的状态类型
	signal status_overed(status_enum: SoraConstant.StatusEnum)
	
	## 状态值变化信号
	## 
	## 当状态值发生任何变化时触发。
	## [param status]: 发生变化的状态信息对象
	signal status_changed(status: StatusInfo)
	
	## 状态类型标识
	var status_enum: SoraConstant.StatusEnum
	
	## 当前状态值
	## 自动处理边界检查，确保值在0到max_value之间
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
	
	## 构造函数
	## 
	## 创建新的状态信息对象。
	## [param _status_enum]: 状态类型，参见 [enum SoraConstant.StatusEnum]
	## [param _value]: 状态的初始值
	## [param _max_value]: 状态的最大值限制
	func _init(_status_enum: SoraConstant.StatusEnum, _value: float, _max_value: float) -> void:
		status_enum = _status_enum
		max_value = _max_value
		value = _value

## 数值信息类
## 
## 用于管理相对稳定的数值属性，如攻击力、防御力等。
## 不具有边界检查和事件触发功能。
class NumInfo:
	## 数值类型标识
	## 
	## 标识数值的类型，参见 [enum SoraConstant.StatusEnum]。
	var status_enum: SoraConstant.StatusEnum
	
	## 数值大小
	## 
	## 存储具体的数值。
	var value: int
	
	## 构造函数
	## 
	## 创建新的数值信息对象。
	## [param _status_enum]: 数值类型，参见 [enum SoraConstant.StatusEnum]
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
	component_name = ComponentName.C_STATUS

## 组件初始化
## 
## 负责收集和配置所有状态扩展，并根据基础信息创建对应的状态对象。
## [param _owner]: 拥有此组件的实体，必须是 [IEntity] 类型
## [param _load_data]: 可选的加载数据，用于恢复保存的状态
func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)
	
	# 收集并初始化所有状态扩展
	for extension in get_children():
		if extension is StatusExtension:
			status_extension[extension.extention_type] = extension
			extension._initialize()
			extension.c_status = self
	
	if SLoadAndSave.current_saved:
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
## 组件更新
## 
## 每帧调用所有状态扩展的效果方法，处理持续性的状态变化。
## [param _delta]: 帧时间间隔，用于时间相关的计算
func _update(_delta: float):
	for extension in status_extension.values():
		extension._effect()

## 状态超限处理
## 
## 当状态值达到临界值时的回调处理，执行相应的游戏逻辑。
## [param _status_enum]: 触发超限的状态类型，参见 [enum SoraConstant.StatusEnum]
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
	return {IComponent.ComponentName.C_STATUS: c_status_returned}

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
