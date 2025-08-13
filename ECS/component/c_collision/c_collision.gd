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
class_name C_Collision
extends IComponent

## 盒子碰撞字典
## 存储所有BoxCollision区域，通过名称进行索引和快速访问
var box_collision: Dictionary[StringName, BoxCollision] = {}

## 盒子射线字典
## 存储所有BoxRay射线检测器，通过名称进行索引和快速访问
var box_rays: Dictionary[StringName, BoxRay] = {}

func _enter_tree() -> void:
	component_name = ComponentName.c_collision

## 组件初始化
## 收集并注册所有子节点中的碰撞检测器
## @param _owner: 拥有此组件的实体
func _initialize(_owner: IEntity):
	super._initialize(_owner)
	
	# 遍历子节点，收集碰撞检测器
	for child in get_children():
		if child is BoxCollision:
			box_collision[child.name] = child
		elif child is BoxRay:
			box_rays[child.name] = child

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

## 启用指定碰撞区域
## @param collision_name: 要启用的碰撞区域名称
func enable_collision(collision_name: StringName):
	var collision = get_collision(collision_name)
	if collision:
		collision.set_deferred("monitoring", true)
		collision.set_deferred("monitorable", true)

## 禁用指定碰撞区域
## @param collision_name: 要禁用的碰撞区域名称
func disable_collision(collision_name: StringName):
	var collision = get_collision(collision_name)
	if collision:
		collision.set_deferred("monitoring", false)
		collision.set_deferred("monitorable", false)

## 启用指定射线检测器
## @param ray_name: 要启用的射线检测器名称
func enable_ray(ray_name: StringName):
	var ray = get_ray(ray_name)
	if ray:
		ray.enabled = true

## 禁用指定射线检测器
## @param ray_name: 要禁用的射线检测器名称
func disable_ray(ray_name: StringName):
	var ray = get_ray(ray_name)
	if ray:
		ray.enabled = false
