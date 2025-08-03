## @editing: Sora [br]
## @describe: 传送交互，进行交互后，开始传送
extends PassiveInteraction

@export var target_level: Level ## 所要传送的楼层
@export var target_point: Entity ## 所会传送到的目标地点

func _on_interact_activated(target_entity: Entity, _component: IComponent):
	target_entity.main_control.global_position = target_point.init_data_variant.get("transported_position") as Vector2
	SMapData.level_changed.emit(target_entity, target_level)

func _on_interact_deactivated(_component: IComponent):
	pass
