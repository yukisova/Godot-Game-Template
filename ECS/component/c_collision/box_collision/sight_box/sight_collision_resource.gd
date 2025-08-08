## SightBox配套的视线生成资源，会根据Sight其中的数据生成信息
class_name SightCollisionResource
extends Resource

enum SightCollisionType{
	Sector, ## 扇形的
	Capsule, ## 胶囊形的
	Rectangle ## 矩形的
}

@export var sight_collision_type: SightCollisionType
@export var sight_wide: float = 2
@export var sight_range: float = 10
@export var sight_offset: Vector2 = Vector2.ZERO
