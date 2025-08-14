## @editing: Sora [br]
## @describe: 行动队列触发组件 - 管理实体的定时行为和特殊动作
## 
## 该组件以模组化的方式为实体绑定各种行为逻辑，如死亡掉落、技能释放、
## 定时行为等。支持基于时间的自动触发和手动激活机制。
## 
## 行为类型：
## - 定时行为：基于游戏时间自动执行的行为
## - 触发行为：响应特定事件的行为
## - 特殊动作：玩家输入或AI决策触发的行为
## - 状态行为：基于实体状态变化的行为
## 
## 功能特性：
## - 模组化行为设计
## - 时间记录系统集成
## - 行为队列管理
## - 与输入系统集成
## - 可扩展的行为类型
@tool
class_name CActionTrigger
extends IComponent

## 行为搜索信号（已废弃）
## 原本用于搜索已有Action，但Action通常可以直接引用，该信号暂无必要
@warning_ignore("unused_signal")
signal _action_searched

## 时间记录数组
## 存储所有定时行为的触发时间配置
@export var time_records: Array[TimeRecord]

func _enter_tree() -> void:
	component_name = ComponentName.C_ACTION_TRIGGER

## 组件初始化
## 将所有子节点中的Action绑定到本组件，便于访问实体信息
## @param _owner: 拥有此组件的实体
func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)
	
	# 绑定所有Action子节点
	for action: Action in get_children():
		action.c_action = self
	
	initialize_complete.emit()

## 时间记录比较
## 检查当前时间是否匹配任何时间记录，并触发对应的行为
## @param current_time: 当前游戏时间（分钟为单位）
func compare_time_record(current_time: int):
	for record in time_records:
		@warning_ignore("integer_division")
		var target_hour = current_time / 60
		var target_minute = current_time % 60
		
		if record.target_hour == target_hour and record.target_minute == target_minute:
			_execute_timed_behavior(record)

## 执行定时行为
## 执行指定时间记录对应的行为
## @param record: 时间记录对象
func _execute_timed_behavior(record: TimeRecord):
	print("实体 ", component_owner.name, " 的定时行为已激活: ", record.target_event_keyword)
	# TODO: 实现具体的行为执行逻辑
	# time_important_coming.emit(record.target_event_keyword)

## 手动触发行为
## 通过代码直接触发指定名称的行为
## @param action_name: 要触发的行为名称
func trigger_action(action_name: String):
	for action: Action in get_children():
		if action.name == action_name:
			action._execute()
			return
	push_warning("行动队列组件: 未找到行为 - ", action_name)

## 添加时间记录
## 动态添加新的定时行为记录
## @param record: 要添加的时间记录
func add_time_record(record: TimeRecord):
	time_records.append(record)

## 移除时间记录
## 移除指定的定时行为记录
## @param record: 要移除的时间记录
func remove_time_record(record: TimeRecord):
	time_records.erase(record)

## 获取所有可用行为
## @return: 所有Action子节点的数组
func get_available_actions() -> Array[Action]:
	var actions: Array[Action] = []
	for child in get_children():
		if child is Action:
			actions.append(child)
	return actions
