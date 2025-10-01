@tool
extends ITriggerAction

var target_entity: IEntity

func _trigger_update(..._args) -> bool:
	target_entity = _args[0] as IEntity
	is_running = true
	target_entity.get_other_component(IComponent.ComponentName.C_COLLISION_BOX).all_disable = true
	target_entity.get_other_component(IComponent.ComponentName.C_STATE_MACHINE).current_temp_state_exported.append("state_attach")
	target_entity.main_control.visible = false
	for i in target_entity.current_collision_group.collision_list:
		i.disabled = true
	
	is_running = false
	return true

func _trigger_update_finish():
	if target_entity:
		target_entity.get_other_component(IComponent.ComponentName.C_COLLISION_BOX).all_disable = false
		target_entity.get_other_component(IComponent.ComponentName.C_STATE_MACHINE).current_temp_state_exported.erase("state_attach")
		target_entity.main_control.visible = true
		for i in target_entity.current_collision_group.collision_list:
			i.disabled = false
func _initialize():
	pass
