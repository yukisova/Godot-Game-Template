class_name SavedDataFile
extends Resource

#region 玩家数据

@export var player_info = {}
#endregion

#region 实体数据

@export var static_entity = {}

#endregion

#region 地图数据

@export var map_cache = {}
## current_map: 当前玩家所在的地图场景对应的文件路径
## current_level: 当前玩家所在的地图层级
## current_room: 当前玩家所在的地图房间

@export var level_info = {}

#endregion

#region 系统数据

@export var blackboard_info = {}

#endregion
