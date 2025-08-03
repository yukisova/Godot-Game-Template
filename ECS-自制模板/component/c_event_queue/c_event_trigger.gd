## 过场行为触发器:
## 在Cutscene或TimeRecord的控制下，目标实体执行指定的动作
class_name C_EventTrigger
extends IComponent

@export var avaiable_events: Dictionary[String, EventQueue]

func _enter_tree() -> void:
	component_name = ComponentName.c_event_trigger

func _initialize(_owner: Entity):
	var time_loop = SSubSystemManager.sub_systems[&"time_loop"] as SSTimeLoop
	time_loop.time_important_coming.connect(event_keyword_check)

func event_keyword_check(keyword: String):
	if avaiable_events.has(keyword):
		avaiable_events[keyword]._running()
