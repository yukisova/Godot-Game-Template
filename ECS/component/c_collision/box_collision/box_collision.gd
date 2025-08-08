## @editing: Sora [br]
## @describe: 打包好的碰撞体的基类，是考虑到很多碰撞体需要进行修饰才设计的
@abstract class_name BoxCollision
extends Area2D

var c_collision : C_Collision

var enable_rotate_by_award: bool = false:
	set(v):
		## 移动组件给予了实体方向的概念，
		if c_collision.component_owner.list_base_components.has(IComponent.ComponentName.c_movement):
			enable_rotate_by_award = v
		else:
			enable_rotate_by_award = false
