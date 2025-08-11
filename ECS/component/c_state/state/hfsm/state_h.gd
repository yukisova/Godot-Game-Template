## @editing: Sora [br]
## @describe: 基于Hfsm的状态基类, 包含过渡与状态拥有者
@tool
@abstract class_name StateHfsm
extends State

## PDA状态推出栈
signal state_poped
## PDA状态压入栈或回滚栈
signal state_pushed(to_state: StatePda)

## HFSM状态切换
@warning_ignore("unused_signal")
signal state_transition(to_state)

## 状态的拥有者
var belong_state_machine: StateMachineHfsm

## 当前状态可过渡到的状态列表
@export var hfsm_state_transition: Dictionary[StringName, TrainsitionRecord]
## 当前状态可能压入的PDA状态
@export var possible_pda_state_push: Array[StatePda]
var confirm_pda_state_dict: Dictionary[String, StatePda]

## 当前状态的状态栈，最终只会执行倒数第一个(即栈顶)的状态
var pda_state_stack: Array[State] = [self]

func _setup():
	state_poped.connect(_on_state_poped)
	state_pushed.connect(_on_state_pushed_rolled)
	
	for i in possible_pda_state_push:
		confirm_pda_state_dict[i.keyword] = i

## PDA状态压入或回滚
func _on_state_pushed_rolled(to_state: StatePda = null):
	var roll_index: int = 0
	if to_state:
		roll_index = pda_state_stack.find(to_state)
	if roll_index == -1:
		if pda_state_stack.size() > 1:
			pda_state_stack[-1].pop_trigger = false
		pda_state_stack[-1]._exit()
		pda_state_stack.push_back(to_state)
		pda_state_stack[-1]._enter()
		pda_state_stack[-1].belong_state = self
	elif roll_index == pda_state_stack.size() - 1:
		return
	else:
		pda_state_stack[-1].pop_trigger = false
		pda_state_stack[-1]._exit()
		pda_state_stack.pop_back()
		while pda_state_stack.size() - 1 > roll_index:
			pda_state_stack.pop_back()
		pda_state_stack[-1]._enter()


## PDA状态推出
func _on_state_poped():
	if pda_state_stack[-1] != self:
		pda_state_stack[-1].belong_state = null
		pda_state_stack[-1].pop_trigger = false
		pda_state_stack[-1]._exit()
		pda_state_stack.pop_back()
		pda_state_stack[-1]._enter()
	else:
		push_error("试图推出头栈，请检查内容")

## 清除栈信息并退出
func _clear_stack_and_exit():
	var exit_flag = pda_state_stack.size() > 1
	pda_state_stack[-1]._exit()

	while pda_state_stack.size() > 1:
		pda_state_stack.pop_back()
	if exit_flag:
		pda_state_stack[-1]._exit()
	

func _f_u(_delta: float) -> void:
	pda_state_stack[-1]._fixed_update(_delta)

## _listen方法在此时代表:是在本状态内持续监听的逻辑
func _u(_delta: float) -> void:
	var top_state = pda_state_stack[-1]
	top_state._update(_delta)
	if top_state is StatePda:
		if top_state.pop_trigger:
			state_poped.emit()
	for i: State in pda_state_stack:
		if i == pda_state_stack[-1] and i != self:
			continue
		i._blur_update(_delta)
	

## 获取可过渡状态
func get_transition_state(keyword: StringName = ""):
	return get_node(hfsm_state_transition[keyword].to_state)

## 当当前状态机为StateMachineHfsm且为根状态机, 则不需要可过渡状态列表
func _validate_property(property: Dictionary) -> void:
	if property.name == "hfsm_state_transition":
		if self is StateMachineHfsm and self.get_parent() is not StateMachineHfsm:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name == "possible_pda_state_push":
		if self is StateMachineHfsm:
			property.usage = PROPERTY_USAGE_NO_EDITOR

func _get_root_statemachine():
	var current = self
	while current is StateHfsm:
		if current is StateMachineHfsm:
			if current.is_root:
				return current
		else:
			current = current.get_parent()
	print("WTF, 根状态机的is_root必须是true")
