## Entity所可能出现的行为，如死亡掉落
@tool
class_name C_Action
extends IComponent


signal _action_searched

func _enter_tree() -> void:
	component_name = ComponentName.c_action

func _initialize(_owner: Entity):
	super(_owner)
	
	for i: Action in get_children():
		i.c_action = self
