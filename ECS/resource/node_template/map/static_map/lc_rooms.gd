class_name LCRooms
extends LevelComponent

signal room_changed(room: Node2D)

var room_list: Array[Room] = []
var current_room: Room:
	set(v):
		if current_room:
			current_room.is_room_visible = false
		current_room = v
		current_room.is_room_visible = true

func _enter_tree():
	if not room_changed.is_connected(_on_room_changed):
		room_changed.connect(_on_room_changed)

func _ready() -> void:
	for room in get_children():
		if room is Room:
			room_list.append(room)
			room.is_room_visible = false
			room.rooms = self

func _initialize():
	if SMapData.current_map.player_spawns[0].current_room in room_list:
		current_room = SMapData.current_map.player_spawns[0].current_room

func _on_room_changed(room: Node2D):
	if room not in room_list: return
	current_room = room
