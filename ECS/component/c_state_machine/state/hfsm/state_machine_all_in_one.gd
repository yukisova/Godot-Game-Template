## 一体化状态机 - 将状态机与子状态逻辑合并的极简实现
##
## 该类是 [StateMachineHfsm] 的极简化版本，将状态机与子状态的逻辑全部整合
## 在一个脚本中。特别适用于只能在 [StaticMap] 中创建的状态机（如NPC的过场行为）。
##
## 设计特点：
## - 单脚本集成：所有状态逻辑集中在一个文件中
## - 基于字典的状态管理：使用 [Dictionary] 存储状态方法
## - [Callable] 封装：过场逻辑用可调用对象包装
## - 灵活切换：状态间切换无严格限制
##
## 核心特性：
## - 极简的状态定义方式
## - 运行时动态状态方法调用
## - 减少节点树复杂度
## - 适合简单的状态逻辑
##
## 应用场景：
## - NPC的简单行为状态机
## - 过场剧情的状态控制
## - 临时性的状态管理需求
## - 需要快速原型开发的场景
##
## 架构设计：
## - 继承自 [StateMachineHfsm] 基类
## - 使用 [annotation @tool] 和 [annotation @abstract] 标记
## - 基于 [Dictionary] 的状态方法存储
## - 通过字符串标识符管理状态
##
## [br][b]编辑者:[/b] Sora
@tool
@abstract class_name StateMachineAIO
extends StateMachineHfsm


## 状态方法字典
## 
## 存储所有状态的方法实现，键为状态名，值为包含enter、update、exit方法的字典。
## 类型为 [Dictionary] of [String] to [Variant]。
var state_method_dict: Dictionary[String, Variant]

## 当前状态字符串标识符
## 
## 与 [member current_state] 变量进行区分，用于确定当前状态的字符串名称。
var current_state_str: String

## 初始状态字符串标识符
## 
## 与 [member init_state] 变量进行区分，用于初始化时的状态名称。
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
