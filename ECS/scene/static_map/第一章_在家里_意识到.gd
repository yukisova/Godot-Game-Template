## 新游戏开场剧情，主角在开始游戏之后会逐步将视角移至中心角色中心
extends ICutscene

@export var dialogue_resource: DialogueResource
func _start():
	await start_caption(dialogue_resource, "", {})
	
	var current_viewport = SViewportManager.get_first_viewport()
	current_viewport.camera_strategy = CFSAttachPlayer.new(Vector2(30, -10))
	var tween = get_tree().create_tween()
	await current_viewport.camera_strategy.tween_offset(Vector2(0, 0), 1.5, tween)
	await SViewportManager.camera_zoom_change_gradually(current_viewport, Vector2(4,4), 1.5)


	

func _finished():
	pass
