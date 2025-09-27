@tool
extends FixedEntity

func _save_as(data: SavedDataFile) -> Dictionary:
	data.player_info = {
		"type": "Initialize",
		"scene_file_path":scene_file_path, ## 有可能角色不一样
		"start_position":global_position,
		"current_position":main_control.global_position,
	}
	var components = {}
	for base_component:IComponent in list_base_components.values():
		components.merge(base_component._save())
	for interface_component:IComponent in list_interface_components.values():
		components.merge(interface_component._save())
	data.player_info["components"] = components

	return {}

func _load_by(data: SavedDataFile) -> Dictionary:
	var player_info = data.player_info
	## 这里不进行任何操作，因为玩家的位置和状态已经在s_main_controller中进行处理了
	
	return data.player_info.get("components", {})

func _despawn():
	print("玩家死亡，弹出游戏结束")
	SSignalBus.game_overed.emit(1)

	
