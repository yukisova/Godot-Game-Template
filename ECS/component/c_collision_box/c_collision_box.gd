@tool
class_name CCollisionBox
extends IComponent

enum BoxCollisionName {
	INTERACT, ## 交互碰撞区域
	HIT,      ## 攻击碰撞区域
	HURT,     ## 受击碰撞区域
	SIGHT,    ## 视野碰撞区域
	SEEK,     ## 搜索碰撞区域
	SOUND,    ## 声音碰撞区域
}
var box_collision: Dictionary[BoxCollisionName, BoxCollision] = {}
var all_disable: bool = false:
	set(v):
		all_disable = v
		if all_disable:
			for i: BoxCollision in box_collision.values():
				i.monitorable = false

enum BoxRayName {
	INTERACT, ## 交互射线
}
var box_rays: Dictionary[BoxRayName, BoxRay] = {}

enum BoxMarkerType {
	TRANSITION, ## 场景切换点
	EFFECT, ## 特效点
	DIALOGUE, ## 浮动对话点
}
var box_markers: Dictionary[BoxMarkerType, BoxMarker] = {}

func _enter_tree() -> void:
	component_name = ComponentName.C_COLLISION_BOX

func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)
	
	for child in get_children():
		if child is BoxCollision:
			box_collision[child.box_collision_name] = child
			child.c_collision = self
		elif child is BoxRay:
			box_rays[child.box_ray_name] = child
			child.c_collision = self
		elif child is BoxMarker:
			box_markers[child.box_marker_name] = child
			child.c_collision = self
	
	initialize_completed.emit()

func _late_initialize():
	for child in box_collision.values():
		child._initialize()
	for child in box_rays.values():
		child._initialize()
	for child in box_markers.values():
		child._initialize()

func _update(_delta: float):
	for collision in box_collision.values():
		collision._update(_delta)
	for ray in box_rays.values():
		ray._update(_delta)

func _fixed_update(_delta: float):
	for collision in box_collision.values():
		collision._fixed_update(_delta)

func get_collision(collision_name: BoxCollisionName) -> BoxCollision:
	return box_collision.get(collision_name)

func get_ray(ray_name: BoxRayName) -> BoxRay:
	return box_rays.get(ray_name)

func get_marker(marker_name: BoxMarkerType) -> BoxMarker:
	return box_markers.get(marker_name)
