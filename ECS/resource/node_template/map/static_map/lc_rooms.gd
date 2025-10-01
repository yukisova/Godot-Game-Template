class_name LCRooms
extends LevelComponent

signal room_changed(room: Node2D)

var room_list: Array[Room] = []

func _enter_tree():
	room_changed.connect(_on_room_changed)

func _initialize():
	for room in get_children():
		if room is Room:
			room_list.append(room)
			room.is_room_visible = false
		
	if SMapData.current_map.player_spawns[0].current_room in room_list:
		SMapData.current_map.player_spawns[0].current_room.is_room_visible = true
	
func _on_room_changed(room: Node2D):
	if room not in room_list: return
	for i in room_list:
		if i == room:
			i.is_room_visible = true
		else:
			i.is_room_visible = false
			for j in i.belongs_entities:
				if j in room.belongs_entities:
					j.modulate = Color.WHITE
