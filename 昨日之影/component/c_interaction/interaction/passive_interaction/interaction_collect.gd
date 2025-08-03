## @editing: Sora [br]
## @describe: 拾取交互（），之后会更加生动
extends PassiveInteraction


@export var binding_item: Item

func _on_interact_activated(_target_entity: Entity ,_component: IComponent):
	var status_in_entity: C_Status = _target_entity.list_base_components.get(IComponent.ComponentName.c_status)
	if status_in_entity != null:
		var inventory_in_entity: InventoryExtension = status_in_entity.status_extension.get(StatusExtension.ExtensionType.背包)
		if inventory_in_entity != null:
			inventory_in_entity.auto_add_inventory(binding_item)

func _on_interact_deactivated(_component: IComponent):
	pass
