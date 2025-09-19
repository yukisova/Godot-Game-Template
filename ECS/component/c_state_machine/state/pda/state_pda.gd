## PDA状态基类 - 下推自动机状态的抽象实现
## 定义PDA（Push-Down Automaton）状态的基础结构，用于实现可中断、可恢复的状态逻辑
## PDA特性：状态标识、状态归属、上下文管理、触发机制、模糊更新
## 应用场景：中断恢复、临时状态、上下文保持、嵌套行为
## [br][b]编辑者:[/b] Sora
@tool
@abstract class_name StatePda
extends IState

@export var plus_trigger_target: Array[StatePda]

var keyword: StringName
var belong_state: StateHfsm
var state_context: Dictionary
var pop_trigger: bool = false:
	set(v):
		pop_trigger = v
		if not v:
			plus_trigger = -1
var plus_trigger: int = -1
var blur_update_enable: bool = false

@abstract func _blur_update(_delta: float)

func set_context(key: String, value: Variant):
	state_context[key] = value

func get_context(key: String, default: Variant = null) -> Variant:
	return state_context.get(key, default)

func pop_request():
	pop_trigger = true

func plus_request():
	plus_trigger = true
