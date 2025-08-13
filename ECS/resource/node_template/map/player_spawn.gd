## @editing: Sora [br]
## @describe: 玩家出生点 - 定义玩家在地图中的初始位置和层级
##
## 该组件用于标记玩家在特定地图中的出生位置：
## - 指定玩家的全局坐标位置
## - 确定玩家所在的地图层级
## - 提供传送和重生的目标点
## - 支持多个出生点的管理
##
## 主要功能：
## - 自动检测和关联所属的Level层级
## - 提供精确的2D坐标定位
## - 支持地图编辑器的可视化标记
## - 集成地图加载和玩家初始化流程
##
## 使用场景：
## - 新游戏的初始出生点
## - 关卡切换的传送目标
## - 死亡复活的重生位置
## - 存档加载的位置恢复
##
## 设计特点：
## - 基于Marker2D的轻量级实现
## - 自动的层级关联检测
## - 错误检查和调试信息
## - 简洁的配置接口
class_name PlayerSpawn
extends Marker2D

#region 层级关联

## 所属的地图层级
## 自动检测并关联的Layer层级引用
var current_level: Level

#endregion

#region 出生点初始化

## 进入场景树时初始化
## 自动检测并关联父级Layer
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

## 获取出生点信息
## @return: 包含位置和层级信息的字典
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
		
