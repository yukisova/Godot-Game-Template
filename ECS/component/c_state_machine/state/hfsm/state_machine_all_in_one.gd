## 一体化状态机 - 将状态机与子状态逻辑合并的极简实现
## StateMachineHfsm的极简化版本，将状态机与子状态逻辑全部整合在一个脚本中
## 设计特点：单脚本集成、基于字典的状态管理、Callable封装、灵活切换
## 应用场景：NPC简单行为状态机、过场剧情状态控制、临时状态管理
## [br][b]编辑者:[/b] Sora
@tool
@abstract class_name StateMachineAIO
extends StateMachineHfsm


## 状态方法字典，存储所有状态的方法实现
var state_method_dict: Dictionary[String, Variant]

## 当前状态字符串标识符，与 current_state 变量进行区分
var current_state_str: String

## 初始状态字符串标识符，与 init_state 变量进行区分
var init_state_str: String

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		notify_property_list_changed()

## 状态机设置（重写方法）
## 
## 连接状态转换信号，初始化状态机。
func _setup() -> void:
	state_transition.connect(_on_state_transition)

## 进入状态（重写方法）
## 
## 调用当前状态的进入方法。
func _enter(): 
	state_method_dict[current_state_str].enter.call()

## 退出状态（重写方法）
## 
## 调用当前状态的退出方法。
func _exit():
	state_method_dict[current_state_str].exit.call()

## 固定更新（重写方法）
## 
## 一体化状态机默认不处理固定更新，子类可根据需要重写。
## [param _delta]: 物理帧时间间隔
func _fixed_update(_delta: float) -> void:
	pass

## 状态更新（重写方法）
## 
## 调用当前状态的更新方法。
## [param _delta]: 帧时间间隔
func _update(_delta: float) -> void:
	state_method_dict[current_state_str].update.call(_delta)

## 状态转换处理
## 
## 处理状态转换请求，执行状态切换逻辑。
## [param to_state]: 目标状态
func _on_state_transition(to_state):
	if current_state_str != (to_state as String):
		_exit()
		current_state_str = to_state
		_enter()

## 获取激活状态（重写方法）
## 
## 一体化状态机不支持HFSM的层次结构。
## [br][br][b]返回:[/b] [StateHfsm] 总是返回null
func _get_active_state() -> StateHfsm:
	push_error("在过场状态机中，不支持HFSM")
	return null

## 获取叶子状态（重写方法）
## 
## 一体化状态机不支持HFSM的层次结构。
## [br][br][b]返回:[/b] [StateHfsm] 总是返回null
func _get_leaf_state() -> StateHfsm:
	push_error("在过场状态机中，不支持HFSM")
	return null

func _validate_property(property: Dictionary) -> void:
	super(property)
	var name_list = ["init_state","current_state"]
	if property.name in name_list:
		property.usage = PROPERTY_USAGE_NO_EDITOR
