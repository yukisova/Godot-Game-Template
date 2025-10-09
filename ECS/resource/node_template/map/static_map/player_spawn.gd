class_name PlayerSpawn
extends Marker2D

## 所属的地图层级
## 自动检测并关联的地图层级引用，类型为 [Level]
@export var current_room: Room:
	get:
		if current_room == null:
			push_error("玩家出生点: 未关联到房间,会出现读取错误")
		return current_room

## 传送点标识符 : 用于进行地图间传送
## 当前传送点的static_map内唯一标识符
@export var transport_point_key: String
