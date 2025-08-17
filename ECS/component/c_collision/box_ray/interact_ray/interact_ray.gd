## 交互射线 - 基于射线检测的精确交互系统
## 
## 该类实现了基于射线投射的交互检测，提供比区域检测更精确的交互定位。
## 主要用于需要精确瞄准或定向交互的场景，如射击、工具使用等。
## 
## 核心功能：
## - 精确的射线碰撞检测
## - 实时的目标追踪系统
## - 智能的实体验证机制
## - 可交互对象的过滤
## 
## 射线交互特性：
## - [b]精确检测[/b]：基于射线的精确碰撞检测
## - [b]实时更新[/b]：每帧更新射线检测结果
## - [b]目标追踪[/b]：自动追踪当前射线指向的交互目标
## - [b]层级过滤[/b]：只检测可交互层级的对象
## 
## 检测流程：
## 1. 每帧强制更新射线检测状态
## 2. 检查射线是否与可交互对象碰撞
## 3. 验证碰撞对象是否为有效实体
## 4. 更新当前交互目标引用
## 5. 提供目标状态查询接口
## 
## 应用场景：
## - 射击游戏：精确的目标瞄准和射击
## - 工具使用：工具对特定物体的操作
## - 远程交互：远距离的精确交互操作
## - 检查功能：查看远处物体的信息
## - 激光瞄准：激光指示器类的功能
## - 建造系统：精确的建筑物放置
##
## 架构设计：
## - 继承自 [BoxRay] 基类
## - 与物理层级系统的集成
## - 基于 [IEntity] 的实体验证
## - 提供完整的目标查询接口
##
## [br][b]编辑者:[/b] Sora
class_name InteractRay
extends BoxRay

## 当前交互目标
## 
## 射线当前指向的可交互实体，null表示没有有效目标，类型为 [IEntity]。
var interact_target: IEntity

## 射线初始化（重写方法）
## 
## 设置射线的碰撞检测层级，只检测可交互对象。
func _enter_tree() -> void:
	box_ray_name = CCollision.BoxRayName.INTERACT
	collision_mask = Main.PhysicsLayer.Interactable

## 射线检测更新（重写方法）
## 
## 每帧更新射线检测状态并更新交互目标。
## [param _delta]: 帧时间间隔，类型为 [float]
func _update(_delta: float):
	# 强制更新射线检测结果
	force_raycast_update()
	
	if is_colliding():
		# 检测到碰撞，验证目标是否为有效实体
		var collider = get_collider()
		if collider and collider.get_parent() is IEntity:
			interact_target = collider.get_parent() as IEntity
		else:
			interact_target = null
	elif interact_target:
		# 没有检测到碰撞，清空当前目标
		interact_target = null

## 获取当前交互目标
## 
## 返回射线当前指向的交互目标。
## [br][br][b]返回:[/b] [IEntity] 当前可交互的实体，如果没有则返回null
func get_current_target() -> IEntity:
	return interact_target

## 检查是否有有效的交互目标
## 
## 快速检查当前是否有可交互的目标。
## [br][br][b]返回:[/b] [bool] 是否存在可交互的目标
func has_target() -> bool:
	return interact_target != null

## 获取交互碰撞点位置
## 
## 返回射线与目标的精确碰撞点坐标。
## [br][br][b]返回:[/b] [Vector2] 射线与目标的碰撞点世界坐标，无碰撞时返回零向量
func get_interact_collision_point() -> Vector2:
	if is_colliding():
		return get_collision_point()
	else:
		return Vector2.ZERO
