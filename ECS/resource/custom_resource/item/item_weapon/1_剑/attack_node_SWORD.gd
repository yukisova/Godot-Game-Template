## 剑的攻击节点，作为近战的节点，用内部的碰撞体代替projectile_scene
## 架构设计：继承自 [WeaponNode] 基类，使用 [SObjectPool] 系统进行实体管理
## [br][b]编辑者:[/b] Sora
@tool
extends WeaponNode

## 近战武器特有的hitbox原型，在activated中复制给玩家的c_collision_box
@export var hitbox_melee_prototype: Dictionary[StringName,HitboxMelee]

var current_hitbox_melee: Array[HitboxMelee] = []

## 武器装备后的
func _activated():
	var c_collision_box: CCollisionBox = c_status.get_other_component(IComponent.ComponentName.C_COLLISION_BOX)
	if !c_collision_box:
		push_error("初始化失败，不存在c_collision_box组件")
		return
	for i in hitbox_melee_prototype.keys():
		var hitbox_melee = hitbox_melee_prototype[i].duplicate()
		hitbox_melee.c_status = c_status
		c_collision_box.add_child(hitbox_melee)

func _trigger_effect(..._args):
	if _args.is_empty(): return
	var hitbox_id = _args[0]
	if hitbox_melee_prototype.has(hitbox_id):
		var c_collision_box:CCollisionBox = c_status.get_other_component(IComponent.ComponentName.C_COLLISION_BOX)
		var hitbox_melee = hitbox_melee_prototype[hitbox_id].duplicate()
		hitbox_melee.c_status = c_status
		hitbox_melee.hit_effects = hitbox_melee_prototype[hitbox_id].hit_effects
		hitbox_melee.rotation = c_collision_box.box_rays.get(CCollisionBox.BoxRayName.INTERACT).rotation
		current_hitbox_melee.append(hitbox_melee)
		hitbox_melee.visible = true
		hitbox_melee.monitorable = true
		hitbox_melee.monitoring = true
		c_collision_box.add_child(hitbox_melee)

		
func _trigger_effect_finished(..._args):
	var c_collision_box:CCollisionBox = c_status.get_other_component(IComponent.ComponentName.C_COLLISION_BOX)
	for hitbox_melee in current_hitbox_melee:
		hitbox_melee.queue_free()
	current_hitbox_melee.clear()
