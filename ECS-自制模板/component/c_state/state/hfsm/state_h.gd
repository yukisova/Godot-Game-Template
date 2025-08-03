## @editing: Sora [br]
## @describe: 基于Hfsm的状态基类, 包含过渡与状态拥有者

@tool
@abstract class_name StateHfsm
extends State

## PDA状态推出栈
signal state_poped
## PDA状态压入栈
signal state_pushed(to_state: StatePda)
## HFSM状态切换
signal state_transition(to_state: StateHfsm)

## 状态的拥有者
var state_owner: Node

## 当前状态可过渡到的状态列表
@export var hfsm_state_transition: Dictionary[StringName, TrainsitionRecord]
## 当前状态的状态栈，最终只会执行倒数第一个(即栈顶)的状态
var pda_state_stack: Array[State] = [self]

func _enter_tree() -> void:
	if !Engine.is_editor_hint():
		state_owner = owner

func _setup():
	state_poped.connect(_on_state_poped)
	state_pushed.connect(_on_state_pushed)

## PDA状态压入
func _on_state_pushed(to_state: StatePda):
	if !(to_state in pda_state_stack):
		pda_state_stack[-1]._exit()
		pda_state_stack.push_back(to_state)
		pda_state_stack[-1]._enter()
	else:
		push_error("尝试推入重复状态")

## PDA状态推出
func _on_state_poped():
	if pda_state_stack[-1] != self:
		pda_state_stack[-1]._exit()
		pda_state_stack.pop_back()
		pda_state_stack[-1]._enter()
	else:
		push_error("试图推出头栈，请检查内容")

## 清除栈信息并退出
func _clear_stack_and_exit():
	pda_state_stack[-1]._exit()
	pda_state_stack.clear()
	pda_state_stack = [self]
	

func _f_u(_delta: float) -> void:
	pda_state_stack[-1]._fixed_update(_delta)

## _listen方法在此时代表:是在本状态内持续监听的逻辑
func _u(_delta: float) -> void:
	_listen()
	pda_state_stack[-1]._update(_delta)

## 获取可过渡状态
func get_transition_state(keyword: StringName = ""):
	return get_node(hfsm_state_transition[keyword].to_state)

## 当当前状态机为StateMachineHfsm且为根状态机, 则不需要可过渡状态列表
func _validate_property(property: Dictionary) -> void:
	if property.name == "hfsm_state_transition":
		if self is StateMachineHfsm and self.get_parent() is not StateMachineHfsm:
			property.usage = PROPERTY_USAGE_NO_EDITOR
