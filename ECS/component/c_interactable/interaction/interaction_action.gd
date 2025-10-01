## 动作交互 - 与i_action结合使用，实现特殊的动作交互
@tool
class_name InteractionAction
extends IInteraction

## 动作结束的方式(Action)
## 1. TimeLimit 时间限制
## 2. Toggle 交互开关
## 3. SignalWait 等待信号

enum ActionEndedType{
	TIME_LIMIT,
	TOGGLE,
	SIGNAL_WAIT
}

@export var action_ended_type: ActionEndedType:
	set(v):
		action_ended_type = v
		notify_property_list_changed()

@export var time_limit: float = 1.0
@export var toggle: bool = false
@export var target_node: Node = self
@export var target_signal_name: StringName

## 默认情况下，interaction_action在每一次触发交互都会以轮询的方式与所有的begin_action进行交互
@export var finish_action: Dictionary[int, ITriggerAction]:
	set(v):
		for i in v.keys():
			if i < begin_action.size() and i >= 0:
				finish_action[i] = v[i]
			else:
				finish_action.erase(i)

var begin_action: Array:
	get:
		return get_children().filter(func(child): return child is ITriggerAction)

var current_action_index: int = 0

func _validate_property(property: Dictionary) -> void:
	var hide_array: Array
	match action_ended_type:
		ActionEndedType.TIME_LIMIT:
			hide_array = ["toggle", "target_node", "target_signal_name"]
		ActionEndedType.TOGGLE:
			hide_array = ["time_limit", "target_node", "target_signal_name"]
		ActionEndedType.SIGNAL_WAIT:
			hide_array = ["toggle", "time_limit"]
	if property.name in hide_array:
		property.usage = PROPERTY_USAGE_NO_EDITOR

func __interact_begin(_target_entity: IEntity):
	current_action_index %= begin_action.size()
	if begin_action[current_action_index].is_running: return
	match action_ended_type:
		ActionEndedType.TIME_LIMIT:
			var index = current_action_index
			if begin_action[current_action_index]._trigger_update(_target_entity):
				current_action_index += 1
				await get_tree().create_timer(time_limit).timeout
				begin_action[index]._trigger_update_finish()
		ActionEndedType.TOGGLE:
			var index = current_action_index
			if toggle:
				current_action_index += 1
				begin_action[index]._trigger_update_finish()
				toggle = not toggle
			else:
				if begin_action[index]._trigger_update(_target_entity):
					toggle = not toggle

			

		#ActionEndedType.SIGNAL_WAIT:
			#begin_action[current_action_index].action_triggered.emit(_target_entity)
			#await target_node.get_signal_list()

func __interact_reset():
	pass
