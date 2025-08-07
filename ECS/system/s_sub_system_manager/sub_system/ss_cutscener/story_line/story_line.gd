## 换句话说是加强版的任务系统，与SS_Cutscener进行联动
## 1. 基础: 确定当前故事的进展方向，影响角色与NPC进行交谈时的信息
## 2. 进阶: 数据缓存，可以在场景进行切换前保存角色通过对话进行的信息，进而影响剧情分支，甚至可以影响角色的游玩分支
## TODO


class_name StoryLine
extends Resource

@export var story_name: String ## 故事的名字
var story_cache: Dictionary ## 故事缓存（不应存储节点的引用，只允许存储基本类型的信息）

## 故事启动的逻辑
func _story_setup():
	pass

## 故事结束的逻辑检查
func _end_check():
	pass
