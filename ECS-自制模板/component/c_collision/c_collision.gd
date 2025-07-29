##@editing:	Sora
##@describe:	实体额外碰撞体组件, 所有的碰撞体基于Area2D, 方便进行引用, 命名为BoxCollision
@tool
class_name C_Collision
extends IComponent

var collision: Dictionary[StringName, BoxCollision] = {}


func _enter_tree() -> void:
	component_name = ComponentName.c_collision

func _initialize(_owner: Entity):
	super._initialize(_owner)
	
	for box in get_children():
		collision[box.name] = box


	
