## @editing: Sora [br]
## @describe: 实体的状态组件，可以使用status_extension类进行扩展, [br]
##			分为两种主要状态 [br]
##			1. StatusInfo: 如血量, 魔力这些需要时刻监控的经常发生变化的信息，并有对应的临界值与临界值触发信号 [br]
##			2. NumInfo: 如攻击力, 这些会影响玩家的战斗体验的数值信息, 不会经常发生改变, 只作为装饰器的量
@tool
class_name C_Status
extends IComponent

## StatusInfo见底
signal status_overred(type: SoraConstant.StatusEnum)

## 初始的状态信息, 没有被明确记录的初始状态默认为零
@export var basic_info: Dictionary[SoraConstant.StatusEnum, float]

## 状态信息, 
class StatusInfo:
	signal status_overed(status_enum: SoraConstant.StatusEnum)
	signal status_changed(status: StatusInfo)
	
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
			status_changed.emit(self)
			
	var max_value: float
	
	func _init(_status_enum: SoraConstant.StatusEnum, _value: float, _max_value: float) -> void:
		status_enum = _status_enum
		max_value = _max_value
		value = _value

## 数值信息
class NumInfo:
	var status_enum: SoraConstant.StatusEnum
	var value: int
	func _init(_status_enum: SoraConstant.StatusEnum, _value: int) -> void:
		status_enum = _status_enum
		value = _value

var status_list: Dictionary[SoraConstant.StatusEnum, StatusInfo] = {} ## 血量，耐力等需要频繁变动的状态信息
var numinfo_list: Dictionary[SoraConstant.StatusEnum, NumInfo] = {} ## 攻击力，防御力等基础数值信息

var status_extension: Dictionary[StatusExtension.ExtensionType, StatusExtension] = {} ## 扩展状态, 如buff之类

func _enter_tree() -> void:
	component_name = ComponentName.c_status

## 初始化: 记录扩展状态与基础状态信息
func _initialize(_owner: Entity):
	super._initialize(_owner)
	
	for extension in get_children():
		if extension is StatusExtension:
			status_extension[extension.extention_type] = extension
			extension._initialize()
	
	for key in basic_info.keys():
		var info = basic_info[key]
		match (key / 100): ## 根据值的范围确认基础信息的类型
			0: ## 状态信息
				status_list[key] = StatusInfo.new(key, info, info)
				status_list[key].status_overed.connect(_on_status_overed)
			1: ## 数值信息
				numinfo_list[key] = NumInfo.new(key, info)
				pass

func _update(_delta: float):
	for i in status_extension.values():
		i._effect()

func _on_status_overed(_status_enum: SoraConstant.StatusEnum):
	status_overred.emit(_status_enum)
	match _status_enum:
		SoraConstant.StatusEnum.Health: ## 角色死亡(有待商榷)
			print(
				"%s被销毁" %
				[component_owner.name]
			)
			component_owner.queue_free.call_deferred()
