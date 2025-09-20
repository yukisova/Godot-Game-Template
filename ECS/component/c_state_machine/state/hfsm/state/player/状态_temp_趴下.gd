@tool
extends StateTemp

func _ready() -> void:
	if (Engine.is_editor_hint()): return

func _enter() -> void:
	pass
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
