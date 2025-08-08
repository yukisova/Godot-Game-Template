##@editing:	Sora
##@describe:PDA状态的基类
@tool
@abstract class_name StatePda
extends State

## 当前的StatePda的关键词，目前还没有想好要不要用UUID代替
var keyword: StringName

## 用于主StateHfsm进行判断，若为真则进行出栈
var pop_trigger: bool = false

func _exit():
	pop_trigger = false
