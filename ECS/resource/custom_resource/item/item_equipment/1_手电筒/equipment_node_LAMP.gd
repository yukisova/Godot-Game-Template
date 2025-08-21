## 手电筒装备，可用于照亮黑暗区域，在加强之后可以让敌人短时间致盲
## 默认放置在玩家左手处，允许旋转
## 架构设计：继承自 [EquipmentNode] 基类
## [br][b]编辑者:[/b] Sora
@tool
extends EquipmentNode

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
func _attack():
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
