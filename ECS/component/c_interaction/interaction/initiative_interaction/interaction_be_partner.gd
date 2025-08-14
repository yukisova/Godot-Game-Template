## 这个目前是由Dialogue进行辅助触发的， 将目标的角色作为玩家的同伴加入队伍，并指定需要进行复制的组件
extends Interaction

@export var partner_scene: PackedScene ## 伙伴的场景信息

@export var partner_copy_list: Array[IComponent]

func _on_interact_activated(target_entity: FixedEntity):
	var partner: FixedEntity = partner_scene.instantiate()
	for i in partner_copy_list:
		var duplicate_component = i.duplicate()
		partner.component_container.add_child(duplicate_component)
	
	SMapData.current_level.add_child(partner)
	partner.global_position = binding_entity.global_position
	partner.main_control.global_position = binding_entity.main_control.global_position
	
	SMainController.partner_joined.emit(partner)
	
	binding_entity.queue_free()
	

func _on_interact_deactivated():
	pass
