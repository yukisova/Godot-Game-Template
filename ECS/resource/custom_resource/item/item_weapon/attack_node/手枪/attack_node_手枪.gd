## @editing: Sora [br]
## @describe: 手枪攻击节点 - 实现手枪的射击攻击逻辑
##
## 该类继承自 WeaponAttackNode，实现了手枪的具体攻击行为。
## 手枪是典型的远程武器，通过发射子弹实体来造成伤害。
##
## 攻击特性：
## - 远程攻击：通过子弹实体实现远距离攻击
## - 精准射击：子弹朝向鼠标位置精确发射
## - 实体系统：子弹作为独立实体，支持复杂的物理和逻辑
## - 初始化数据：通过 init_data 系统配置子弹属性
##
## 攻击流程：
## 1. 玩家触发攻击（通常是鼠标点击）
## 2. 实例化子弹场景
## 3. 计算从发射点到鼠标位置的方向向量
## 4. 配置子弹的初始位置和飞行方向
## 5. 将子弹添加到当前关卡场景
##
## 技术实现：
## - 使用 PackedScene 加载子弹预制体
## - 通过 setter 验证子弹场景的有效性
## - 利用实体初始化数据系统传递参数
## - 基于鼠标位置计算射击方向
##
## 配置说明：
## - projectile_scene: 子弹实体的场景文件
## - fire_point: 继承自基类的发射点标记
##
## 使用示例：
## ```gdscript
## # 在编辑器中配置
## var pistol_node = preload("res://weapons/pistol_attack_node.tscn").instantiate()
## pistol_node.projectile_scene = preload("res://projectiles/bullet.tscn")
## ```
@tool
extends WeaponAttackNode

## 子弹场景预制体
## 定义了子弹实体的场景文件，必须是 TempEntity 类型的场景
## 使用自定义 setter 确保场景的有效性验证
@export var projectile_scene: PackedScene:
	set(v):
		if v == null:
			projectile_scene = v
			projectil_pool_key = &""
			return
		# 验证场景是否为有效的TempEntity场景
		var node = v.instantiate()
		if node is TempEntity:
			projectile_scene = v
			projectil_pool_key = node.pool_key
		else:
			push_error("攻击节点: 子弹场景必须是TempEntity类型")
		node.queue_free()

var projectil_pool_key: StringName = &""
## 子弹对象池初始大小
## 预分配的子弹实体数量，根据游戏需求调整
@export var initial_pool_size: int = 30

## 初始化手枪攻击系统
## 注册子弹对象池，确保对象池系统可用
func _ready():
	super()
	if Engine.is_editor_hint():
		return
	
	# 注册子弹对象池
	_register_bullet_pool()
	SMapData.level_changed_finished_for_player.connect(_register_bullet_pool)

## 注册子弹对象池
## 在对象池系统中注册子弹实体，用于高效的子弹管理
func _register_bullet_pool():
	if projectile_scene == null:
		push_error("手枪攻击节点: 未设置子弹场景，无法注册对象池")
		return

	# 检查对象池是否已经注册
	var pool_stats = SObjectPool._pools
	if !pool_stats.has(projectil_pool_key):
		# 注册新的对象池
		SObjectPool.register_pool(projectil_pool_key, projectile_scene, initial_pool_size)
		print("手枪攻击节点: 子弹对象池已注册 - 池标识: %s, 初始大小: %d" % [projectil_pool_key, initial_pool_size])
	else:
		print("手枪攻击节点: 子弹对象池已存在 - %s" % projectil_pool_key)

## 手枪攻击实现（对象池版本）
## 执行手枪的射击攻击，从对象池获取子弹实体并发射
## 
## 攻击步骤：
## 1. 从对象池获取子弹实体
## 2. 计算射击方向（基于碰撞组件的朝向）
## 3. 配置子弹的初始化上下文数据
## 4. 对象池自动将子弹添加到当前层级
##
## 优势：
## - 高效的内存管理：避免频繁创建/销毁子弹
## - 自动层级管理：子弹自动添加到正确的地图层级
## - 性能优化：预分配对象池减少运行时开销
##
## 注意事项：
## - 子弹的具体行为由TempEntity自身定义
## - 发射方向基于角色的朝向计算
## - 使用全局坐标系确保位置准确性
func _attack():
	if projectile_scene == null:
		push_error("手枪攻击节点: 未设置子弹场景")
		return
	
	# 获取角色碰撞组件以计算射击方向
	var c_collision: CCollision = c_status.component_owner.list_base_components[IComponent.ComponentName.C_COLLISION]
	if c_collision == null:
		push_error("手枪攻击节点: 找不到碰撞组件，无法计算射击方向")
		return
	
	# 计算射击方向（基于角色朝向）
	var shoot_direction = (Vector2.RIGHT).rotated(c_collision.box_rays[CCollision.BoxRayName.INTERACT].rotation)
	
	# 准备子弹初始化上下文数据
	var bullet_context = {
		"start_direction": shoot_direction,
		"source_entity": c_status.component_owner,  # 子弹来源实体
		"hit_effect_list": hit_effect_list,
		"speed": 500.0  # 子弹速度（可以根据武器属性调整）
	}
	
	# 从对象池生成子弹实体
	SObjectPool._spawn(
		projectil_pool_key,
		projectile_scene,
		bullet_context,
		fire_point.global_position
	)
	
