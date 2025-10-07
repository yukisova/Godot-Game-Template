@tool
extends StateTemp

@export var ray_interact_confirm: REInteractConfirm
@export var movement_input: REMovementInput

func _ready() -> void:
	if (Engine.is_editor_hint()): return

func _enter() -> void:
	ray_interact_confirm.ray_toward_by_mouse = false
	movement_input.disabled = true
	
func _exit() -> void:
	ray_interact_confirm.ray_toward_by_mouse = true
	movement_input.disabled = false

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
