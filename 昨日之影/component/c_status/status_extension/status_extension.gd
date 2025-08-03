## @editing: Sora [br]
## @describe: 背包等复杂特殊状态的状态
@abstract class_name StatusExtension
extends Node

enum ExtensionType{
	背包,
	临时效果
}

var extention_type: ExtensionType

@abstract func _initialize()

@abstract func _effect()
