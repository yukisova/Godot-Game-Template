## @editing: Sora [br]
## @describe: 碰撞组件 - 管理实体的额外碰撞检测区域和射线检测
## 
## 该组件提供了基于Area2D和RayCast2D的碰撞检测系统，用于处理实体与
## 环境、其他实体之间的交互检测。支持多个命名的碰撞区域和射线。
## 
## 碰撞检测类型：
## - BoxCollision：基于Area2D的区域碰撞检测
## - BoxRay：基于RayCast2D的射线碰撞检测
## 
## 功能特性：
## - 命名的碰撞区域管理
## - 多重碰撞检测支持
## - 动态碰撞区域配置
## - 高效的碰撞查询接口
## - 与交互系统集成
@tool
class_name CCollision
extends IComponent

## 盒子碰撞字典
## 存储所有BoxCollision区域，通过名称进行索引和快速访问
enum BoxCollisionName {
	INTERACT,
	HIT,
	HURT,
	SIGHT,
	SEEK,
}
var box_collision: Dictionary[BoxCollisionName, BoxCollision] = {}

## 盒子射线字典
## 存储所有BoxRay射线检测器，通过名称进行索引和快速访问
enum BoxRayName {
	INTERACT,
}
var box_rays: Dictionary[BoxRayName, BoxRay] = {}

func _enter_tree() -> void:
	component_name = ComponentName.C_COLLISION

## 组件初始化
## 收集并注册所有子节点中的碰撞检测器
## @param _owner: 拥有此组件的实体
func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)
	
	# 遍历子节点，收集碰撞检测器
	for child in get_children():
		if child is BoxCollision:
			box_collision[child.box_collision_name] = child
			child.c_collision = self
		elif child is BoxRay:
			box_rays[child.box_ray_name] = child
			child.c_collision = self
	
	initialize_complete.emit()

func _update(_delta: float):
	for collision in box_collision.values():
		collision._update(_delta)
	for ray in box_rays.values():
		ray._update(_delta)

## 获取指定名称的碰撞区域
## @param collision_name: 碰撞区域的名称
## @return: BoxCollision对象，如果不存在则返回null
func get_collision(collision_name: StringName) -> BoxCollision:
	return box_collision.get(collision_name)

## 获取指定名称的射线检测器
## @param ray_name: 射线检测器的名称
## @return: BoxRay对象，如果不存在则返回null
func get_ray(ray_name: StringName) -> BoxRay:
	return box_rays.get(ray_name)