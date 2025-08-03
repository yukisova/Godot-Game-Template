## @editing: Sora [br]
## @describe: 不规则的地图(特指手绘的地图场景)
class_name PolygonTile
extends Sprite2D

@export var terrain_polygon: Polygon2D
@export var static_body: StaticBody2D

func _ready() -> void:
	if terrain_polygon.polygons.is_empty() and !terrain_polygon.polygon.is_empty():
		var start_polygon = range(terrain_polygon.polygon.size())
		terrain_polygon.polygons.append(PackedInt32Array(start_polygon))
		
	for indecies in terrain_polygon.polygons:
		var points: PackedVector2Array = recombine_arrays_safe(indecies, terrain_polygon.polygon)
		create_collision_for_polygon(points)

func create_collision_for_polygon(polygon: PackedVector2Array):
	var collision = CollisionPolygon2D.new()
	collision.polygon = polygon
	collision.build_mode = CollisionPolygon2D.BUILD_SEGMENTS
	static_body.add_child(collision)

## 返回基于索引数组的子多边形
func recombine_arrays_safe(indices: Array, target: PackedVector2Array) -> PackedVector2Array:
	if !indices.is_empty():
		return PackedVector2Array(indices.filter(func(index): 
			return index >= 0 and index < target.size()
		).map(func(valid_index):
			return target[valid_index]
		))
	else:
		return target
