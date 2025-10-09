@tool
extends StateTemp

@export var movement_input: REMovementInput
@export var equipment: EquipmentExtension

func _ready() -> void:
	if (Engine.is_editor_hint()): return

func _enter() -> void:
	movement_input.toward_mode = movement_input.TowardMode.MOUSE
	if equipment.current_equipment:
		equipment.current_equipment_node.set_aim_type()

func _exit() -> void:
	movement_input.toward_mode = movement_input.TowardMode.MOVE
	if equipment.current_equipment:
		equipment.current_equipment_node.set_normal_type()

func _blur_update(_delta: float) -> void:
	pass
func _update(_delta: float) -> void:
	pass
func _fixed_update(_delta: float) -> void:
	pass

func _pause() -> void:
	pass
func _continue() -> void:
	pass
