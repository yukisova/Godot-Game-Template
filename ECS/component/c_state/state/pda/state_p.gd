## @editing: Sora
## @describe: PDA状态的基类
@tool
@abstract class_name StatePda
extends State

## 当前的StatePda的关键词，目前还没有想好要不要用UUID代替
var keyword: StringName
var belong_state: StateHfsm
var state_context: Dictionary ## 状态的上下文信息，由stateHFSM提供

## 用于主StateHfsm进行判断，若为真则进行出栈
var pop_trigger: bool = false:
	set(v):
		pop_trigger = v
		if !v:
			plus_trigger = v
## 与pop_trigger相似，但是这是满足了PDA内部既定目标的时候用于主StateHfsm
var plus_trigger: bool = false
var blur_update_enable: bool = false

## 失焦但暂时没有失去联系时的update逻辑, 效果与listen类似(之后可能将listen的效果进行重合)
func _blur_update(_delta: float):
	pass
