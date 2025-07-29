## @editing: Sora
## @describe: 基于Hfsm的状态基类, 包含过渡与状态拥有者

@tool
@abstract class_name StateHfsm
extends State

signal state_poped
signal state_pushed(to_state: StatePda)

signal state_transition(to_state: StateHfsm)

var state_owner: Node

@export var hfsm_state_transition: Dictionary[StringName, TrainsitionRecord]
var pda_state_stack: Array[State] = [self]

func _enter_tree() -> void:
	if !Engine.is_editor_hint():
		state_owner = owner

## FIXME 位于StateHfsm中的setup方法与PDA的目的就是应对突发的状态，不应当以预定义的方式进行设计
## 改善手段: 1. 将_state_poped做入Hfsm状态内
func _setup():
	state_poped.connect(_on_state_poped)
	state_pushed.connect(_on_state_pushed)

func _on_state_pushed(to_state: StatePda):
	if !(to_state in pda_state_stack):
		pda_state_stack[-1]._exit()
		pda_state_stack.push_back(to_state)
		pda_state_stack[-1]._enter()
	else:
		push_error("尝试推入重复状态")

func _on_state_poped():
	if pda_state_stack[-1] != self:
		pda_state_stack[-1]._exit()
		pda_state_stack.pop_back()
		pda_state_stack[-1]._enter()
	else:
		push_error("试图推出头栈，请检查内容")

func _clear_stack_and_exit():
	pda_state_stack[-1]._exit()
	pda_state_stack.clear()
	pda_state_stack = [self]
	

func _f_u(_delta: float) -> void:
	pda_state_stack[-1]._fixed_update(_delta)

func _u(_delta: float) -> void:
	_listen()
	pda_state_stack[-1]._update(_delta)

func get_transition_state(keyword: StringName = ""):
	return get_node(hfsm_state_transition[keyword].to_state)

func _validate_property(property: Dictionary) -> void:
	if property.name == "hfsm_state_transition":
		if self is StateMachineHfsm and self.get_parent() is not StateMachineHfsm:
			property.usage = PROPERTY_USAGE_NO_EDITOR
