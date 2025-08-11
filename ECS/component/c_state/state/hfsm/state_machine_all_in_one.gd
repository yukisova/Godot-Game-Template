## 即StateMachine all in one ，将状态机与子状态的逻辑全部写在一个脚本里并搭载在一个节点上
## 是StateMachineHfsm的极简化，用于一些只能在StaticMap中创建的状态机(例如一个NPC的实时)
## 运行的过场全部用Callable包裹的信息代替，将原本在要在节点内展现的逻辑简化在一个代码当中
## 为了方便处理，各个状态间的切换不存在严格的限制
@tool
@abstract class_name StateMachineAIO
extends StateMachineHfsm


var state_method_dict: Dictionary[String, Variant]
var current_state_str: String ## 与current_state变量进行区分的用于确定当前状态的当前状态名
var init_state_str: String ## 与init_state变量进行区分用于初始化的的初始状态名

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		notify_property_list_changed()

## 此处定义
func _setup() -> void:
	state_transition.connect(_on_state_transition)

func _enter(): 
	state_method_dict[current_state_str].enter.call()

func _exit():
	state_method_dict[current_state_str].exit.call()

func _fixed_update(_delta: float) -> void:
	pass

func _update(_delta: float) -> void:
	state_method_dict[current_state_str].update.call(_delta)

func _on_state_transition(to_state):
	if current_state_str != (to_state as String):
		_exit()
		current_state_str = to_state
		_enter()

func _get_active_state() -> StateHfsm:
	push_error("在过场状态机中，不支持HFSM")
	return null
func _get_leaf_state() -> StateHfsm:
	push_error("在过场状态机中，不支持HFSM")
	return null

func _validate_property(property: Dictionary) -> void:
	super(property)
	var name_list = ["init_state","current_state"]
	if property.name in name_list:
		property.usage = PROPERTY_USAGE_NO_EDITOR
