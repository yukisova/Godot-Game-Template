## 碰撞组件 - 管理实体的额外碰撞检测区域和射线检测
##
## 该组件提供了基于 [Area2D] 和 [RayCast2D] 的碰撞检测系统，用于处理实体与
## 环境、其他实体之间的交互检测。支持多个命名的碰撞区域和射线。
##
## 碰撞检测类型：
## - [BoxCollision]：基于 [Area2D] 的区域碰撞检测
## - [BoxRay]：基于 [RayCast2D] 的射线碰撞检测
##
## 功能特性：
## - 命名的碰撞区域管理
## - 多重碰撞检测支持
## - 动态碰撞区域配置
## - 高效的碰撞查询接口
## - 与交互系统集成
##
## 碰撞区域类型：
## - [constant BoxCollisionName.INTERACT]：交互区域
## - [constant BoxCollisionName.HIT]：攻击判定区域
## - [constant BoxCollisionName.HURT]：受击判定区域
## - [constant BoxCollisionName.SIGHT]：视野检测区域
## - [constant BoxCollisionName.SEEK]：搜索区域
##
## [br][b]编辑者:[/b] Sora
@tool
class_name CCollision
extends IComponent

## 盒子碰撞名称枚举
## 
## 定义不同类型的碰撞区域标识符。
enum BoxCollisionName {
	INTERACT, ## 交互碰撞区域 - 用于触发交互事件
	HIT,      ## 攻击碰撞区域 - 用于攻击判定
	HURT,     ## 受击碰撞区域 - 用于受伤判定
	SIGHT,    ## 视野碰撞区域 - 用于AI视野检测
	SEEK,     ## 搜索碰撞区域 - 用于目标搜索
}

## 盒子碰撞字典
## 
## 存储所有 [BoxCollision] 区域，通过名称进行索引和快速访问。
var box_collision: Dictionary[BoxCollisionName, BoxCollision] = {}

## 盒子射线名称枚举
## 
## 定义不同类型的射线检测器标识符。
enum BoxRayName {
	INTERACT, ## 交互射线 - 用于精确的交互检测
}

## 盒子射线字典
## 
## 存储所有 [BoxRay] 射线检测器，通过名称进行索引和快速访问。
var box_rays: Dictionary[BoxRayName, BoxRay] = {}

func _enter_tree() -> void:
	component_name = ComponentName.C_COLLISION

## 组件初始化
## 
## 收集并注册所有子节点中的碰撞检测器，建立检测器与组件的关联。
## [param _owner]: 拥有此组件的实体，必须是 [IEntity] 类型
## [param _load_data]: 可选的加载数据，用于恢复保存的状态
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

## 组件更新
## 
## 每帧更新所有碰撞检测器的状态。
## [param _delta]: 帧时间间隔，用于时间相关的更新计算
func _update(_delta: float):
	for collision in box_collision.values():
		collision._update(_delta)
	for ray in box_rays.values():
		ray._update(_delta)

## 获取指定名称的碰撞区域
## 
## 根据名称查找对应的碰撞检测区域。
## [param collision_name]: 碰撞区域的名称，参见 [enum BoxCollisionName]
## [br][br][b]返回:[/b] [BoxCollision] 对象，如果不存在则返回null
func get_collision(collision_name: StringName) -> BoxCollision:
	return box_collision.get(collision_name)

## 获取指定名称的射线检测器
## 
## 根据名称查找对应的射线检测器。
## [param ray_name]: 射线检测器的名称，参见 [enum BoxRayName]
## [br][br][b]返回:[/b] [BoxRay] 对象，如果不存在则返回null
func get_ray(ray_name: StringName) -> BoxRay:
	return box_rays.get(ray_name)