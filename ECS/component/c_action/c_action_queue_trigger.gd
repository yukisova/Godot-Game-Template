## @editing: Sora [br]
## @describe: 指定Entity所可能出现的行为的具体逻辑，以模组的方式进行绑定，如死亡掉落。[br]
## 				潜力：可以定义玩家的一些特殊动作，并使用InputListener进行激活

## 
@tool
class_name C_ActionQueueTrigger
extends IComponent

@warning_ignore("unused_signal")
signal _action_searched ## FIXME 这里原本的目的是用于搜索已有的Action,但是Action往往是可以直接引用的, 这个信号目前似乎没有存在的必要

@export var time_records: Array[TimeRecord]

func _enter_tree() -> void:
	component_name = ComponentName.c_action_queue_trigger

## 初始化: 将子节点下的Action类绑定自身, 方便获取实体信息
func _initialize(_owner: IEntity):
	super(_owner)
	
	for i: Action in get_children():
		i.c_action = self

## 对当前的使用
func compare_time_record(current_time: int):
	for record in time_records:
		@warning_ignore("integer_division")
		if record.target_hour == current_time / 60:
			if record.target_minute == current_time % 60:
				
				print("角色的定时行为已被激活! 但还没有写逻辑")
				# time_important_coming.emit(record.target_event_keyword)