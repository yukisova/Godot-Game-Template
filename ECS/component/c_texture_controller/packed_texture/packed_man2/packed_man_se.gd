extends IPackedSprite

func try_animation(animation_name: String) -> bool:
	
	var animation_player = packed_sprite_editor.animation_player

	if animation_player == null:
		return false

	if animation_player.has_animation(animation_name):
		animation_player.play(animation_name,-1, 2)
		await animation_player.animation_finished
		animation_player.play("RESET")
		return true

	return false
