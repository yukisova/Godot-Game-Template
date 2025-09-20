@tool
extends StateTemp

@export var action_input_map: ActionInputMap
@export var c_texture_controller: CTextureController

func _ready() -> void:
	if (Engine.is_editor_hint()): return

func _enter() -> void:
	c_texture_controller.packed_sprite.packed_sprite_editor.try_switch_texture("Hiding")
func _exit() -> void:
	pass

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
