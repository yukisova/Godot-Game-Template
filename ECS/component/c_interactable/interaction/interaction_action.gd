## 动作交互 - 与i_action结合使用，实现特殊的动作交互
class_name InteractionAction
extends IInteraction

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

func __interact_begin(_target_entity: IEntity):
	current_action_index %= begin_action.size()
	begin_action[current_action_index].action_triggered.emit(_target_entity)
	current_action_index += 1

func __interact_reset():
	pass
