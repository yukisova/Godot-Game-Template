##@editing:	Sora
##@describe:	交互组件，可以实现基于被动或主动的交互
@tool
class_name C_Interactable
extends IComponent

signal interact_activated ## 开始交互信号
signal interact_deactivated ## 取消交互信号

enum InteractCollisionSource{ 
	依赖实体, ## 当前的交互组件碰撞体来自实体对象自身的ComponentBody
	自定义碰撞体 ## 当前的交互组件碰撞体来自定义的引用
}

@export var interact_inherit_mode: InteractCollisionSource : ## 交互碰撞体来源
	set(v):
		interact_inherit_mode = v
		notify_property_list_changed()

@export var interact_object: CollisionObject2D :## 自定义交互碰撞体
	set(v):
		interact_object = v
		notify_property_list_changed()

@export var area_is_passive: bool ## 在交互碰撞体为Area2D的情况下确定交互碰撞体是主动触发还是被动触发
@export var interaction: Interaction ## 交互所关联的目标逻辑组件


func _enter_tree() -> void:
	component_name = ComponentName.c_interaction

func _initialize(_owner: Entity):
	super._initialize(_owner)
	
	interact_activated.connect(interaction._on_interact_activated.bind(self))
	interact_deactivated.connect(interaction._on_interact_deactivated.bind(self))
	
	var final_body
	
	if interact_inherit_mode == InteractCollisionSource.依赖实体:
		final_body = component_body
		if final_body is Area2D:
			final_body.body_entered.connect(
				func(_body: Node2D):
					if _body.is_in_group("player"):
						if area_is_passive:
							interact_activated.emit()
						else:
							var entity = _body.owner as Entity
							if entity.list_base_components.has(IComponent.ComponentName.c_input_reactor):
								var c_input = entity.list_base_components[IComponent.ComponentName.c_input_reactor]
								c_input.interact_obj = self
			)
			final_body.body_exited.connect(
				func(_body: Node2D):
					if _body.is_in_group("player"):
						interact_deactivated.emit()
						if not area_is_passive:
							var entity = _body.owner as Entity
							if entity.list_base_components.has(IComponent.ComponentName.c_input_reactor):
								var c_input = entity.list_base_components[IComponent.ComponentName.c_input_reactor]
								c_input.interact_obj = null
			)
	else:
		final_body = interact_object
		if final_body is Area2D:
			final_body.body_entered.connect(
				func(_body: Node2D):
					if _body.is_in_group("player"):
						if area_is_passive:
							interact_activated.emit()
						else:
							var entity = _body.owner as Entity
							if entity.list_base_components.has(IComponent.ComponentName.c_input_reactor):
								var c_input = entity.list_base_components[IComponent.ComponentName.c_input_reactor]
								c_input.interact_obj = self
			)
			final_body.body_exited.connect(
				func(_body: Node2D):
					if _body.is_in_group("player"):
						interact_deactivated.emit()
						if not area_is_passive:
							var entity = _body.owner as Entity
							if entity.list_base_components.has(IComponent.ComponentName.c_input_reactor):
								var c_input = entity.list_base_components[IComponent.ComponentName.c_input_reactor]
								c_input.interact_obj = null
			)

func _validate_property(property: Dictionary) -> void:
	match interact_inherit_mode:
		InteractCollisionSource.依赖实体:
			var list_name = ["interact_object"]
			if property.name in list_name:
				property.usage = PROPERTY_USAGE_NO_EDITOR
			if component_body is not Area2D:
				if property.name == "area_is_passive":
					property.usage = PROPERTY_USAGE_NO_EDITOR
		InteractCollisionSource.自定义碰撞体:
			if interact_object is not Area2D:
				if property.name == "area_is_passive":
					property.usage = PROPERTY_USAGE_NO_EDITOR
