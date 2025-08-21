## 手枪攻击节点 - 实现手枪的射击攻击逻辑
## 该类继承自 [WeaponNode]，实现了手枪的具体攻击行为
## 手枪是典型的远程武器，通过发射子弹实体来造成伤害，集成了对象池系统
## 核心功能：远程攻击、精准射击、对象池优化、自动注册
## 攻击特性：基于角色朝向的射击方向计算、实体系统、初始化数据、层级管理
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
func _trigger_effect():
	if not projectile_scene:
		return
	
	# 获取角色朝向
	var direction: Vector2 = Vector2.RIGHT
	var collision_box = get_parent().get_parent().get_node("CCollisionBox") as CCollisionBox
	if collision_box and collision_box.hit_box:
		direction = collision_box.hit_box.get_toward_direction()
	
	# 从对象池获取子弹
	var context = {"direction": direction}
	SObjectPool.get_object(projectile_scene, global_position, context)

#endregion

#region 对象池管理
## 注册子弹到对象池系统
func _register_to_pool():
	if projectile_scene:
		SObjectPool.register_object(projectile_scene, initial_pool_size)

#endregion
