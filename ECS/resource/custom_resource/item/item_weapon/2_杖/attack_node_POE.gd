## 架构设计：继承自 [WeaponNode] 基类，使用 [SObjectPool] 系统进行实体管理
## [br][b]编辑者:[/b] Sora
@tool
extends WeaponNode

#region 射弹配置
## 子弹场景
## 手枪发射的子弹实体预制体
@export var projectile_scene: PackedScene:
	set(value):
		if value:
			var instance = value.instantiate()
			projectile_scene = value
			instance.queue_free()

## 对象池初始大小
## 预分配的子弹实体数量，用于性能优化
@export var initial_pool_size: int = 20

#endregion

#region 攻击实现
## 实现具体的手枪攻击逻辑
## 从对象池获取子弹，配置射击方向和初始化数据
func _trigger_effect(..._args):
	if not projectile_scene:
		return

	# 获取角色朝向
	var direction: Vector2 = Vector2.RIGHT
	var collision_box : CCollisionBox = c_status.get_other_component(IComponent.ComponentName.C_COLLISION_BOX) as CCollisionBox
	var interact_ray:InteractRay = collision_box.box_rays.get(CCollisionBox.BoxRayName.INTERACT)
	if interact_ray:
		direction = direction.rotated(interact_ray.rotation)


	# 从对象池获取子弹
	var context = {"start_direction": direction}
	SObjectPool._spawn("projectile", projectile_scene, context, fire_point.global_position)

#endregion

#region 对象池管理
## 注册子弹到对象池系统
func _register_to_pool():
	if projectile_scene:
		SObjectPool.register_pool("projectile", projectile_scene, initial_pool_size)

#endregion
