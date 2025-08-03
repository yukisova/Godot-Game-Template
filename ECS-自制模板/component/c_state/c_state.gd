## @editing: Sora [br]
## @describe: 状态机组件, 需要使用时请选择同名的子场景。
@tool
class_name C_State
extends IComponent

## 所使用的多层有限状态机的根状态机, 见[StateMachineHfsm]
@export var root_state_machine: StateMachineHfsm
## 所使用的离散的下推状态集节点, 
@export var pda_states: Node
## 在下推状态集节点[member C_State.pda_states]中收集到的下推状态.
## 为了方便进行引用, 会借助下推状态[StatePda]中的关键词keyword构建字典
## 但是keyword并非uuid, 由程序员自己进行维护
var pda_state_dict: Dictionary[StringName, StatePda]

func _enter_tree() -> void:
	component_name = ComponentName.c_state

## 初始化: 记录所有下推状态,启动并登入状态机
func _initialize(_owner: Entity):
	super._initialize(_owner)
	
	for i in pda_states.get_children():
		if i is StatePda:
			pda_state_dict[i.keyword] = i
	
	root_state_machine._setup()
	root_state_machine._enter()

func _update(_delta: float):
	root_state_machine._update(_delta)

func _fixed_update(_delta: float):
	root_state_machine._fixed_update(_delta)
