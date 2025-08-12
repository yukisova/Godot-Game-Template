## 玩家的实体，重写了某些逻辑为了与其他实体区分开来正确保存在s_main_control当中
@tool
extends IEntity

func _save_as(data: SavedDataFile):
	data.player_info = {
		"scene_file_path":scene_file_path, ## 有可能角色不一样
		"start_position":global_position,
		"current_position":main_control.global_position,
		"current_level_index":get_parent().get_index()
	}
	return {}

func _load_by(data: SavedDataFile, ...args):
	var player_info = data.player_info

	global_position = player_info["start_position"]
	main_control.global_position = player_info["current_position"]
