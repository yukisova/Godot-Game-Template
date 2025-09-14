## 碰撞组件 - 管理实体的碰撞检测区域和射线检测
## 基于Area2D和RayCast2D的碰撞检测系统，支持命名的碰撞区域管理
## 支持交互、攻击、受击、视野、搜索等碰撞类型
## [br][b]编辑者:[/b] Sora
@tool
class_name CCollisionBox
extends IComponent

## 盒子碰撞名称枚举
## 定义不同类型的碰撞区域标识符
enum BoxCollisionName {
	INTERACT, ## 交互碰撞区域
	HIT,      ## 攻击碰撞区域
	HURT,     ## 受击碰撞区域
	SIGHT,    ## 视野碰撞区域
	SEEK,     ## 搜索碰撞区域
	SOUND,    ## 声音碰撞区域
}

## 盒子碰撞字典
## 存储所有[BoxCollision]区域，通过名称索引
var box_collision: Dictionary[BoxCollisionName, BoxCollision] = {}

## 盒子射线名称枚举
## 定义不同类型的射线检测器标识符
enum BoxRayName {
	INTERACT, ## 交互射线
}

## 盒子射线字典
## 存储所有[BoxRay]射线检测器，通过名称索引
var box_rays: Dictionary[BoxRayName, BoxRay] = {}

## 标记类型枚举
## 定义不同类型的标记用途
enum BoxMarkerType {
	TRANSITION, ## 场景切换点
	EFFECT, ## 特效点
	DIALOGUE, ## 浮动对话点
}

var box_markers: Dictionary[BoxMarkerType, BoxMarker] = {}



func _enter_tree() -> void:
	component_name = ComponentName.C_COLLISION_BOX

## 收集并注册所有子节点中的碰撞检测器
## [param _owner]: 拥有此组件的实体
## [param _load_data]: 可选的加载数据
func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)
	
	# 遍历子节点，收集碰撞检测器
	# 没有位于CCollisionBox下的盒子碰撞体需要手动绑定
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
	
	initialize_complete.emit()

func _late_initialize():
	for child in box_collision.values():
		child._initialize()
	for child in box_rays.values():
		child._initialize()
	for child in box_markers.values():
		child._initialize()

## 每帧更新所有碰撞检测器状态
## [param _delta]: 帧时间间隔
func _update(_delta: float):
	for collision in box_collision.values():
		collision._update(_delta)
	for ray in box_rays.values():
		ray._update(_delta)

## 根据名称获取碰撞区域
## [param collision_name]: 碰撞区域名称
func get_collision(collision_name: StringName) -> BoxCollision:
	return box_collision.get(collision_name)

## 根据名称获取射线检测器
## [param ray_name]: 射线检测器名称
func get_ray(ray_name: StringName) -> BoxRay:
	return box_rays.get(ray_name)
