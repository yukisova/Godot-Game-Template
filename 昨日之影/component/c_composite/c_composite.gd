## @editing: Sora [br]
## @describe: 指定实体所绑定的纹理动效, 如飘在人物头部的DialogueBallon [br]
##			  难点：需要大量借助Tween [br]
##			  目前的主要作用
@tool
class_name C_Composite
extends IComponent

var composites_dict: Dictionary[StringName, Control] = {}

func _enter_tree() -> void:
	component_name = ComponentName.c_composite

func _initialize(_owner: Entity):
	for i: Control in get_children():
		composites_dict[i.name] = i

func _target_fade_in(target_composite: StringName):
	var composite = composites_dict.get(target_composite)
	composite

func _target_fade_out():
	pass
