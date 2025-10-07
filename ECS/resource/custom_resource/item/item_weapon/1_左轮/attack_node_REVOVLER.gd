## 架构设计：继承自 [WeaponNode] 基类，使用 [SObjectPool] 系统进行实体管理
## [br][b]编辑者:[/b] Sora
@tool
extends WeaponNode

#region 射弹配置
## 子弹场景
## 手枪发射的子弹实体预制体
@export var limit_fire: bool = true

@export var projectile_scene: PackedScene

## 子弹发射音频 wav格式
@export var shoot_audios: Dictionary[String, AudioStream]

@export var 随机散射数量: Vector2i:
	set(v):
		v = abs(v)
		if v.x > v.y : 
			v = Vector2(v.y, v.x)
		随机散射数量 = v
@export var 随机距离范围区间: Vector2:
	set(v):
		v = abs(v)
		if v.x > v.y : 
			v = Vector2(v.y, v.x)
		随机距离范围区间 = v
@export var 角度偏移区间: float:
	set(v):
		角度偏移区间 = clampf(v, 0, 180)
		

## 对象池初始大小
## 预分配的子弹实体数量，用于性能优化
@export var initial_pool_size: int = 20

#endregion

#region 抛物线攻击实现
## 实现具体的手枪攻击逻辑
## 从对象池获取子弹，配置射击方向和初始化数据
func _trigger_effect(..._args):
	if not projectile_scene:
		return
		
	var current_index = source_item.current_index
	var current_bullet_clip_num = source_item.current_bullet_clip_num
	var next_index = (current_index + 1) % current_bullet_clip_num

	var current_bullet_clip_type = source_item.bullet_clip[current_index]
	
	if limit_fire:
		match current_bullet_clip_type:
			BulletClipSlot.BulletClipType.BULLET:
				print("当前弹仓有子弹,可以进行发射")
				_shoot_effect()
				source_item.bullet_clip[current_index] = BulletClipSlot.BulletClipType.BULLET_OVER
			BulletClipSlot.BulletClipType.BULLET_OVER:
				print("当前弹仓子弹已发射，无法进行发射")
			BulletClipSlot.BulletClipType.EMPTY:
				print("当前弹仓没有子弹，无法进行发射")
	else:
		_shoot_effect()
	
	## 旋转弹巢
	print("当前弹巢索引", source_item.current_index)
	source_item.current_index = next_index
	
## 播放发射子弹的音效
func _shoot_audio(_name: String):
	if shoot_audios.has(_name):
		SAudioMaster.play_sfx(shoot_audios[_name])

## 播放发射子弹的动画_tween
func _shoot_animation():
	var camera_viewport = SViewportManager.get_viewport_container(c_status.component_body)
	SViewportManager.camera_shake(camera_viewport, 3)
	var tween: Tween = get_tree().create_tween()
	var rotation_var = -20
	var position_var = Vector2(0, -2)
	if texture.flip_v:
		rotation_var = 20
		position_var = Vector2(0, 2)
	tween.tween_property(self, "rotation_degrees", rotation_var, 0.2)
	tween.set_parallel(true).tween_property(self, "position", position_var, 0.2)
	tween.set_parallel(false)
	tween.tween_property(self, "rotation_degrees", 0, 0.8)
	tween.set_parallel(true).tween_property(self, "position", Vector2.ZERO, 0.8)
	

## 播放发射子弹时的粒子效果
func _shoot_spread_effect():
	pass

## 发射子弹效果
func _shoot_effect():
	_shoot_audio("fire")
	_shoot_animation()
	_shoot_spread_effect()

	var direction: Vector2 = Vector2.RIGHT
	var fire_offset = 10
	var collision_box : CCollisionBox = c_status.get_other_component(IComponent.ComponentName.C_COLLISION_BOX) as CCollisionBox
	
	#var interact_ray:InteractRay = collision_box.box_rays.get(CCollisionBox.BoxRayName.INTERACT)
	#if interact_ray:
		#direction = direction.rotated(interact_ray.rotation)
	
	var rand_num = randi_range(随机散射数量.x, 随机散射数量.y)
	
	var hand_offset_y = c_status.get_other_component(IComponent.ComponentName.C_TEXTURE_CONTROLLER).packed_sprite.packed_sprite_editor.hand_offset_y
	for i in rand_num:
		var start_position = c_status.component_body.global_position + direction * fire_offset
		var rand_angle = randf_range(-角度偏移区间, 角度偏移区间)
		var rand_range = randf_range(随机距离范围区间.x, 随机距离范围区间.y)
		var context = {"start_direction": direction.rotated(deg_to_rad(rand_angle)), "target_range": rand_range }
		SObjectPool._spawn("projectile", projectile_scene, context, start_position)

func _shoot_failed():
	_shoot_audio("failed")
#endregion

#region 对象池管理
## 注册子弹到对象池系统
func _register_to_pool():
	if projectile_scene:
		SObjectPool.register_pool("projectile", projectile_scene, initial_pool_size)

func _activated():
	pass

func _deactivated():
	pass
#endregion
