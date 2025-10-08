## 开关交互，用于实现类似电灯开关，门开关的功能
@tool
class_name InteractionSwitch
extends IInteraction

@export var switch_target: Dictionary[Node, StringName] = {}

var current_state: bool:
	set(v):
		current_state = v
		for p: Node in switch_target.keys():
			var property: StringName = switch_target[p]
			if p:
				p.set(property, current_state)

func _ready() -> void:
	current_state = false

func __interact_begin(_target_entity: IEntity) -> bool:
	current_state = !current_state
	return true

func __interact_reset():
	pass
