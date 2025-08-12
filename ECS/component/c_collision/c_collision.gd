## @editing: Sora [br]
## @describe: 实体额外碰撞体组件, 所有的碰撞体基于Area2D与RayCast2D, 方便进行引用, 命名为BoxCollision
@tool
class_name C_Collision
extends IComponent

## 存放BoxCollision的字典, 要使用的时候顺序引用
var box_collision: Dictionary[StringName, BoxCollision] = {}
var box_rays: Dictionary[StringName, BoxRay] = {}


func _enter_tree() -> void:
	component_name = ComponentName.c_collision

## 初始化: 
func _initialize(_owner: IEntity):
	super._initialize(_owner)
	
	for i in get_children():
		if i is BoxCollision:
			box_collision[i.name] = i
		elif i is BoxRay:
			box_rays[i.name] = i


	
