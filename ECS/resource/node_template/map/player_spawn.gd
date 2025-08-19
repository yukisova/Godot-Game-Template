## 玩家出生点 - 定义玩家在地图中的初始位置和层级
## 该组件用于标记玩家在特定地图中的出生位置，提供完整的位置管理功能
## 集成地图层级系统，确保玩家能在正确的位置和层级中生成
## 核心功能：指定玩家的全局坐标位置、确定玩家所在的地图层级、提供传送和重生的目标点
## 使用场景：新游戏的初始出生点、关卡切换的传送目标、死亡复活的重生位置
## 设计特点：基于 [Marker2D] 的轻量级实现、自动的层级关联检测机制
## 架构设计：继承自 [Marker2D] 基类，与 [Level] 层级系统的自动关联
## [br][b]编辑者:[/b] Sora
class_name PlayerSpawn
extends Marker2D

#region 层级关联

## 所属的地图层级
## 自动检测并关联的地图层级引用，类型为 [Level]
var current_level: Level

#endregion

#region 出生点初始化

## 自动检测并关联父级 [Level] 层级
func _enter_tree() -> void:
	print("玩家出生点: 开始初始化")
	
	var parent = get_parent()
	if parent is Level:
		current_level = parent
		print("玩家出生点: 成功关联到层级 -> ", parent.name)
	else:
		push_error("玩家出生点: 错误的父节点类型，应放置在Level层级下")

#endregion

#region 位置信息获取

## 获取包含位置和层级信息的完整出生点数据
## [br][br][b]返回:[/b] [Dictionary] 包含位置和层级信息的字典
func get_spawn_info() -> Dictionary:
	var level_name_value: String
	if current_level:
		level_name_value = current_level.name
	else:
		level_name_value = "unknown"
	
	return {
		"position": global_position,
		"level": current_level,
		"level_name": level_name_value
	}

#endregion
		
