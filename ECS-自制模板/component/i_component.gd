## 组件基类, 分为插件组件和固定组件
abstract class_name IComponent
extends Node

enum ComponentType { BASE = 0, INTERFACE = 1 }
enum ComponentName {
	c_action = 0,
	c_animation,
	c_camera,
	c_collision,
	c_input,
	c_interaction,
	c_move,
	c_statemachine,
	c_status,
	c_weapon,
	c_navigation
}

var component_name: ComponentName

var component_owner: Entity ## 组件的拥有者
var component_body: CollisionObject2D
var component_type: ComponentType:
	set(value):
		if (Engine.is_editor_hint()):
			component_type = value
		else:
			printerr(
				"该量运行时不可修改。"
			)
	get:
		return component_type

##
func _initialize(_owner: Entity):
	if Engine.is_editor_hint():
		return
	component_owner = _owner
	component_body = component_owner.body


##
func _late_initialize(_owner: Entity):
	if Engine.is_editor_hint():
		return
	component_owner = _owner
	component_body = component_owner.body

func _update(_delta: float):
	if Engine.is_editor_hint():
		return

func _fixed_update(_delta: float):
	if Engine.is_editor_hint():
		return


func _late_update(_delta: float):
	if Engine.is_editor_hint():
		return


func _trigger_update():
	if Engine.is_editor_hint():
		return


func _exit_tree() -> void:
	return
