## 存档系统， 
extends ISystem

## 游戏保存
signal saving_started

## 游戏加载开始——期间会等待所有的加载项加载完毕
signal loading_started

## 游戏加载
signal loading_refreshed(data: Dictionary)

const SAVE_PATH := "user://data.sav"

func _enter_tree() -> void:
	Main.s_load_and_save = self
	
	
	saving_started.connect(_data_saving)
	loading_started.connect(_data_loading)

func _data_saving():
	# var scene := get_tree().current_scene ## 获取场景信息
	# var scene_name := scene.scene_file_path.get_file().get_basename() ## 获取场景名
	
	var data := {}
	var json := JSON.stringify(data) ## 字符化字典
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		return
	file.store_string(json)

## 游戏内数据的加载
func _data_loading():
	var result = {}
	var datafile := FileAccess.open(SAVE_PATH, FileAccess.READ)
	#var setting := FileAccess.open()
	if not datafile:
		return
	
	var json_for_savingfile := datafile.get_as_text()
	var data := JSON.parse_string(json_for_savingfile) as Dictionary
	result.merge(result, true)
	print("目前的存档文件内容为: ",data)
	loading_refreshed.emit.call_deferred(result)
