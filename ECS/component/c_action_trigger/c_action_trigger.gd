## 行动队列触发组件 - 管理实体的定时行为和特殊动作
## 该组件以模组化的方式为实体绑定各种行为逻辑，如死亡掉落、技能释放、定时行为等
## 支持基于时间的自动触发和手动激活机制
## 行为类型：定时行为、触发行为、特殊动作、状态行为
## 功能特性：模组化行为设计、时间记录系统集成、行为队列管理
## 架构设计：基于 [IAction] 的行为封装，通过 [TimeRecord] 管理定时触发
## [br][b]编辑者:[/b] Sora
@tool
class_name CActionTrigger
extends IComponent

## 当前动作列表
## 用于记录当前动作的列表, 供状态机[CStateMachine]与纹理控制器[CTextureController]使用
var current_action_list: Dictionary[IAction, StringName] = {}

## 移动策略列表
## 专门用于处理移动策略的列表, 栈顶的列表为主移动策略，由外界优先访问
var move_strategy: Array[MoveStrategy] = []


@export_group("动作逻辑注册表", "action_list_")
## 定时触发动作列表
## 会在特定时间点触发的动作逻辑，详见 [TimeRecord] 类
@export var _action_list_time_record: Array[TimeRecord]

func _enter_tree() -> void:
	component_name = ComponentName.C_ACTION_TRIGGER

## 持续监听动作列表
## 需要进行持续监听的动作逻辑，比如被合并的移动逻辑
var _action_list_update: Array[IUpdateAction]

## 将所有子节点中的Action绑定到本组件，便于访问实体信息
## [param _owner]: 拥有此组件的实体，类型为 [IEntity]
## [param _load_data]: 可选的加载数据，用于恢复保存的状态
func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)

	initialize_completed.emit()
	# 绑定所有Action子节点
	for action in get_children():
		if action is IAction:
			action.c_action = self
			if action is IUpdateAction:
				_action_list_update.append(action)
				current_action_list[action as IAction] = action.current_action_state
				if action is MoveStrategy:
					move_strategy.append(action)
			elif action is ITriggerAction:
				action.action_state_output.connect(_on_action_state_output)
			action._initialize()
		
	initialize_completed.emit()

#region 触发监听相关

func _on_action_state_output(action: ITriggerAction):
	current_action_list[action as IAction] = action.current_action_state

#endregion


#region 持续监听相关
func _update(_delta: float):
	for action in _action_list_update:
		action._update(_delta)

func _reset():
	for action in _action_list_update:
		action._reset()
#endregion

#region 时间记录相关
## 检查当前时间是否匹配任何时间记录，并触发对应的行为
## [param current_time]: 当前游戏时间（分钟为单位）
func compare_time_record(current_time: int):
	for record in _action_list_time_record:
		@warning_ignore("integer_division")
		var target_hour = current_time / 60
		var target_minute = current_time % 60
		
		if record.target_hour == target_hour and record.target_minute == target_minute:
			_execute_timed_behavior(record)

## 执行指定时间记录对应的行为
## [param record]: 时间记录对象，类型为 [TimeRecord]
func _execute_timed_behavior(record: TimeRecord):
	print("实体 ", component_owner.name, " 的定时行为已激活: ", record.target_event_keyword)
	# TODO: 实现具体的行为执行逻辑
	# time_important_coming.emit(record.target_event_keyword)

## 动态添加新的定时行为记录
## [param record]: 要添加的时间记录，类型为 [TimeRecord]
func add_time_record(record: TimeRecord):
	_action_list_time_record.append(record)

## 移除指定的定时行为记录
## [param record]: 要移除的时间记录，类型为 [TimeRecord]
func remove_time_record(record: TimeRecord):
	_action_list_time_record.erase(record)

#endregion

## 获取所有可用行为
## [br][br][b]返回:[/b] [Array] 包含所有 [IAction] 子节点的数组
func get_available_actions() -> Array[IAction]:
	var actions: Array[IAction] = []
	for child in get_children():
		if child is IAction:
			actions.append(child)
	return actions
