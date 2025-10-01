extends ICutscene

@export_file_path("*.dialogue") var dialogue_resource

func _start():
	await get_tree().process_frame
	
	var entity_state_manager : LCEntityStates = SMapData.current_level.entity_state_manager
	var player: IEntity = SMainController._get_player_info_by_index(0)
	entity_state_manager.set_all_entity_visible([player], false)
	entity_state_manager.set_all_tilemap_layer_visible([], false)
	
	SUiSpawner._hide_all_hud([])
	await start_dialogue(load(dialogue_resource), "talk_start_prototype", {})
	SUiSpawner._hide_all_hud([""])
	entity_state_manager.set_all_entity_visible([], true)
	entity_state_manager.set_all_tilemap_layer_visible([], true)



func _finished():
	pass
