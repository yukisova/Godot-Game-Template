## 游戏内的分支剧情选项缓存, 
## 更加适合作为游戏内的子系统
## TODO 还没加入游戏内
class_name SSStoryer
extends SubSystem

## 想象中的 - 每一章单独设计一个固定的流程，加载游戏的时候进行读取？

func _update(_delta: float):
	pass

func _setup():
	keyword = &"storyer"
	pass

#region :存档系统，将黑板的信息全部保存下来:
func _save_as(_data: SavedDataFile) -> Dictionary:
	var result = {}

	return {
		keyword:result
	}

func _load_by(_data: SavedDataFile):
	pass
#endregion