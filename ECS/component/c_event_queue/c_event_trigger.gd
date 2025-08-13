## @editing: Sora [br]
## @describe: 事件触发组件 - 响应时间和场景事件的行为触发器
## 
## 该组件用于在特定的时间点或场景条件下触发实体的预定义行为。
## 主要用于实现过场动画、定时事件、剧情触发等功能。
## 
## 触发条件：
## - 时间循环系统的时间点事件
## - 过场动画（Cutscene）的时间记录
## - 自定义的关键词事件
## 
## 功能特性：
## - 基于关键词的事件映射
## - 与时间循环系统集成
## - 支持多个并发事件队列
## - 事件队列管理
@tool
class_name C_EventTrigger
extends IComponent

## 可用事件字典
## 存储关键词到事件队列的映射，用于响应不同的触发条件
@export var avaiable_events: Dictionary[String, EventQueue]

func _enter_tree() -> void:
	component_name = ComponentName.c_event_trigger

## 组件初始化
## 连接到时间循环系统，监听重要时间点事件
## @param _owner: 拥有此组件的实体
func _initialize(_owner: IEntity):
	super._initialize(_owner)
	
	# 连接时间循环系统的重要时间点信号
	var time_loop = SBlackboard.sub_systems.get(&"time_loop") as SSTimeLoop
	if time_loop:
		time_loop.time_important_coming.connect(event_keyword_check)
	else:
		push_warning("事件触发组件: 未找到时间循环子系统")

## 事件关键词检查
## 当接收到时间重要事件时，检查是否有对应的事件队列需要执行
## @param keyword: 事件关键词
func event_keyword_check(keyword: String):
	if avaiable_events.has(keyword):
		avaiable_events[keyword]._running()
	else:
		print("事件触发组件: 未找到关键词对应的事件 - ", keyword)

## 手动触发事件
## 通过代码直接触发指定关键词的事件
## @param keyword: 要触发的事件关键词
func trigger_event(keyword: String):
	event_keyword_check(keyword)

## 添加事件
## 动态添加新的事件到可用事件字典中
## @param keyword: 事件关键词
## @param event_queue: 事件队列对象
func add_event(keyword: String, event_queue: EventQueue):
	avaiable_events[keyword] = event_queue

## 移除事件
## 从可用事件字典中移除指定关键词的事件
## @param keyword: 要移除的事件关键词
func remove_event(keyword: String):
	avaiable_events.erase(keyword)
