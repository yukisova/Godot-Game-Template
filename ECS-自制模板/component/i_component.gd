## @editing: Sora [br]
## @describe: 组件基类, 分为插件组件和固定组件
@abstract class_name IComponent
extends Node

enum ComponentType { ## 组件的状态
	BASE = 0, ## 基础组件，在实体编辑时固定的基础性组件
	INTERFACE ## 接口组件, 直接挂载在诸如地图一类的实体子场景下，或通过代码动态挂载在目标实体下。主要面向可能会根据地图信息, 角色行为而需要灵活设置信息的场景
}
enum ComponentName {
	c_action = 0, ## 见[C_Action]
	c_texture, ## 见[C_Texture]
	c_camera, ## 见[C_Camera]
	c_collision, ## 见[C_Collision]
	c_input_reactor, ## 见[C_InputReactor]
	c_interaction, ## 见[C_Interactable]
	c_movement, ## 见[C_Movement]
	c_state, ## 见[C_State]
	c_status, ## 见[C_Status]
	c_navigation, ## 见[C_Navigation]
	c_composite, ## 见[C_Composite]
	c_event_trigger, ## 见[C_EventTrigger]
}

var component_owner: Entity ## 组件的拥有者, 即实体
var component_body: CollisionObject2D ## 实体的主碰撞体
var component_name: ComponentName ## 用于实体内组件字典进行识别的类型枚举
var component_type: ComponentType: ## 实体的类型
	set(value):
		if (Engine.is_editor_hint()):
			component_type = value
		else:
			printerr(
				"该量运行时不可修改。"
			)
	get:
		return component_type
var component_context: Dictionary = {} ## 组件的上下文


func _initialize(_owner: Entity):
	if Engine.is_editor_hint():
		return
	component_owner = _owner
	component_body = component_owner.body

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


func get_controller() -> IComponent :
	var input = component_owner.list_base_components.get(ComponentName.c_input_reactor)
	return input
