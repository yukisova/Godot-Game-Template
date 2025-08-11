## @editing: 线段碰撞体组件
## 本身是C_Collision的另一个扩展，主要用于进行指定距离的定位，如攻击范围的确定，与
## C
class_name C_Ray
extends IComponent

var box_rays: Array[BoxRay]

func _enter_tree() -> void:
	component_name = ComponentName.c_ray

func _initialize(_owner: IEntity):
	super(_owner)
	for i in get_children():
		if i is BoxRay:
			box_rays.append(i)
	

func _update(_delta: float):
	for i in box_rays:
		i._update(_delta)
