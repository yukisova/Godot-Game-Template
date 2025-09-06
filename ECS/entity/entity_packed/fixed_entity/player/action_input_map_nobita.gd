
extends ActionInputMap

func _match_action(action_id: int):
	match action_id:
		0:
			_primary_action()
		1:
			_secondary_action()
		2:
			_special_action()
		3:
			_skill_1()

func _trigger_update_finish():
	pass

func _primary_action():

	var equipment_extension: EquipmentExtension = c_status.get_status_extension(StatusExtension.ExtensionType.EQUIPMENT)
	if equipment_extension:
		if equipment_extension.current_attack_node:
			equipment_extension.current_attack_node._trigger_effect()
		else:
			print("没有当前攻击节点")
		print("你好")

func _secondary_action():
	# c_status.status_extension[StatusExtension.ExtensionType.EQUIPMENT].current_equipment_node
	pass
func _special_action():
	pass
func _skill_1():
	pass
func _skill_2():
	pass
