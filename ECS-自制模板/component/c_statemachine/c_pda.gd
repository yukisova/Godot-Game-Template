## 下推自动机，实际就是将栈的思想代替原本的信息
@tool
class_name C_Pda
extends IComponent

@export var root_state_machine: StateMachine
var state_stack: Array[State] = []  # 状态栈
var blackboard := {}  # 共享数据

# 状态栈操作信号
signal stack_pushed(state: State)
signal stack_popped(state: State)

func _initialize(_owner: Entity):
	super._initialize(_owner)
	root_state_machine._enter()
	root_state_machine._setup()
	
	state_stack.push_back(root_state_machine.current_state)  # 初始状态入栈

func push_state(state: State):
	peek_state()._exit()
	state_stack.push_back(state) ## 将当前的状态加入状态栈
	state._enter() 
	stack_pushed.emit(state)

func pop_state():
	## 应当防止空状态下根状态被弹出
	if state_stack.size() <= 1: 
		return
	var old_state = state_stack.pop_back()
	old_state._exit()
	peek_state()._enter()
	stack_popped.emit(old_state)

func peek_state() -> State:
	return state_stack[-1]  # 栈顶为当前状态

func _update(_delta: float):
	peek_state()._update(_delta)

func _fixed_update(_delta: float):
	peek_state()._fixed_update(_delta)
