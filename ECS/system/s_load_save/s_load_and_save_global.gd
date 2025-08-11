## @editing: Sora [br]
## @describe: 存档系统， 同时可以保存游戏运行时的全局共享数据，效果类似黑板
extends ISystem

## 游戏保存
@warning_ignore("unused_signal")
signal saving_started

## 游戏加载开始——期间会等待所有的加载项加载完毕
signal loading_started
## 游戏加载
signal loading_refreshed(data: Dictionary)
## 默认的保存文件名
const SAVE_PATH := "user://data.sav"

## FIXME 位于存档系统中的全局黑板 游戏运行时的缓存信息(方便全局共享，相当于一个黑板)，但目前还没有用上，如果有更好的方案的话，可以直接删去
var gaming_data_cache: Dictionary = {}

func _enter_tree() -> void:
	saving_started.connect(_data_saving)
	loading_started.connect(_data_loading)
	

func _resetup():
	gaming_data_cache.clear()


## 发出存档信号的时候，会递归获取到所有的可存档信息
func _data_saving():
	var data := {}
	data.merge(SBlackboard._save_as())
	data.merge(SMapData._save_as())

	
	var save_data = SavedDataFile.new()	
	save_data.save_data = data

	ResourceSaver.save(save_data, "user://sav.tres") ## FIXME 在游戏开发阶段建议使用的
	print("数据已经成功保存！")

## 游戏内数据的加载
func _data_loading():
	var data: SavedDataFile = ResourceLoader.load("user://sav.tres")


	# loading_refreshed.emit.call_deferred(result)