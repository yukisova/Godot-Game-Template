extends ICutscene

@export_file_path("*.dialogue") var dialogue_resource

func _start():
	await get_tree().process_frame
	
	var rooms: LCRooms = SMapData.current_level.rooms
	var player: IEntity = SMainController._get_player_info_by_index(0)
	rooms.current_room.is_room_visible = false
	
	SUiSpawner._hide_all_hud([])
	await start_dialogue(load(dialogue_resource), "talk_start_prototype", {})
	SUiSpawner._hide_all_hud(["", "transition"])

	rooms.current_room.is_room_visible = true

func _finished():
	pass
