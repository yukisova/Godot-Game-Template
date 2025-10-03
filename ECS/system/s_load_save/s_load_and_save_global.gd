extends ISystem

@warning_ignore("unused_signal")
signal saving_started(id: int)
signal loading_started(id: int)

var current_saved: SavedDataFile = null

func _enter_tree() -> void:
	saving_started.connect(_data_saving)
	loading_started.connect(_data_loading)

## 当选择新游戏或者游戏初次打开的时候，会自动生成一个预设的新游戏存档文件，
## 用于沉浸式的预加载场景，不会保存到磁盘
## 在系统进行初始化加载的时候，会自动读取存档数据，判断最近的存档，并预加载场景以进行快速的游戏。
## 追求House类似的丝滑的游戏加载体验
func _setup():
	pass

func _resetup():
	current_saved = null

## 获取最近的存档文件
func get_all_formal_save_files():
	var save_files = []
	for file in DirAccess.get_files_at("user://save/"):
		if file.ends_with(".tres"):
			save_files.append(file)
	return save_files

func get_latest_save_file():
	var result
	if FileAccess.file_exists("user://save/save_latest.tres"):
		result = ResourceLoader.load("user://save/save_latest.tres")
		if result == null:
			push_error("存档系统: 快速存档文件加载失败")
			return null
	return result

## 游戏初始地图
@export var new_game_basic_map: PackedScene
## 测试用地图
@export var test_game_basic_map: PackedScene

## 在主菜单中预加载游戏场景，如果最近存档不存在则创建一个新游戏
func preload_game_in_ui_main():
	## 会选择最近存档，如果没有则创建一个新游戏
	var save_file = get_latest_save_file()
	if save_file == null:
		save_file = await create_and_load_new_game()
	await SSignalBus.game_data_loaded_compelete
	SSignalBus.game_data_preloaded.emit()

func create_and_load_new_game():
	var data = SavedDataFile.new()
	var init_data = await SMapData.map_info_preload(new_game_basic_map)

	data.player_info = init_data.get("player_info", {})
	data.map_cache = init_data.get("map_cache", {})

	return data

func create_and_load_test_game():
	var data = SavedDataFile.new()
	var init_data = await SMapData.map_info_preload(test_game_basic_map)

	data.player_info = init_data.get("player_info", {})
	data.map_cache = init_data.get("map_cache", {})

	return data

#region 游戏的存档和读档操作，需要在完善好其他子实体的存档字段后在进行设计
func _data_saving(id: int = -1):
	print("存档系统: 开始保存游戏数据...")
	
	var data = SavedDataFile.new()
	
	SBlackboard._data_saving(data)
	await SMapData._data_saving(data)

	var save_path : String
	if id == -1:
		save_path = "user://save/save_latest.tres"
	else:
		save_path = "user://save/save_" + str(id) + ".tres"

	var error = ResourceSaver.save(data, save_path)
	
	if error == OK:
		print("存档系统: 数据保存成功 -> ", save_path)
	else:
		push_error("存档系统: 数据保存失败，错误代码: " + str(error))

func _data_loading(id: int = -1):
	print("存档系统: 开始加载游戏数据...")
	var save_path : String
	var temp_load_flag = false
	if id == -1:
		save_path = "user://save/save_latest.tres"
		temp_load_flag = true
	else:
		save_path = "user://save/save_" + str(id) + ".tres"

	if not FileAccess.file_exists(save_path):
		push_warning("存档系统: 存档文件不存在 -> " + save_path)
		return
	
	var data: SavedDataFile = ResourceLoader.load(save_path)
	if data == null:
		push_error("存档系统: 存档文件加载失败 -> " + save_path)
		return
	
	current_saved = data
	
	SBlackboard._data_loading(data)
	SMapData._data_loading(data)

	## 快速存档对应的文件会在加载完成后自动删除
	if temp_load_flag:
		DirAccess.remove_absolute(save_path)

	print("存档系统: 数据加载完成")

func _test_save():
	pass
