## @editing: Sora [br]
## @describe: 未指定玩家出生点的地图内，玩家的出生点 [br]
##			  主要的点是指定玩家所在的层级与所在的global_position
class_name PlayerSpawn
extends Node2D

## 用于确定玩家初始化时所在的楼层
var current_level: Level

func _enter_tree() -> void:
	var parent = get_parent()
	if parent is Level:
		current_level = parent
	else:
		push_error("应当将玩家出生点放在指定层下！")
		
