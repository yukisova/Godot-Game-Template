extends Action

@export var c_status: C_Status

func _effect(...args):
    var equipment: EquipmentExtension = c_status.status_extension[StatusExtension.ExtensionType.EQUIPMENT]
    if equipment.current_attack_node != null:
        equipment.current_attack_node.attack()
