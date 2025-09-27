@tool
class_name Hurtbox
extends BoxCollision

# 受击信号
signal just_suffered(hurt_effect_list: Array[IHitEffect])

func _enter_tree() -> void:
	box_collision_name = CCollisionBox.BoxCollisionName.HURT
	collision_layer = Main.PhysicsLayer.Breakable
	collision_mask = Main.PhysicsLayer.Breakable

func _ready() -> void:
	just_suffered.connect(_on_just_suffered)

func _on_just_suffered(hurt_effect_list: Array[IHitEffect]):
	var c_status: CStatusList = c_collision.get_other_component(IComponent.ComponentName.C_STATUS_LIST)
	for hurt_effect in hurt_effect_list:
		if hurt_effect is StatusEffect:
			if c_status.status_list.has(hurt_effect.status_effect_target):
				c_status.status_list[hurt_effect.status_effect_target].value += hurt_effect.status_effect_value
			else:
				push_error("实体", c_status.component_owner.name, "不存在状态", hurt_effect.status_effect_target)

		elif hurt_effect is BuffEffect:
			pass
		elif hurt_effect is CountedEffect:
			pass



	# var c_status: CStatusList = c_collision.get_other_component(IComponent.ComponentName.C_STATUS_LIST)
	# if c_status and c_status.status_list.has(SoraConstant.StatusEnum.Health):
	# 	c_status.status_list[SoraConstant.StatusEnum.Health].value -= hit_damage
	# else:
	# 	push_error("实体", c_status.component_owner.name, "不存在健康状态")
	
	# _hurted_animation()
	# _hurted_particle(hitbox)
	# _hurted_decal(hitbox)

	# print("实体受伤: ", hit_damage, " 点伤害", )

func _calculate_hit(hitbox: IHitbox) -> int:
	var hit_effect_list: Array[IHitEffect] = hitbox.get_hit_effects()
	var c_status: CStatusList = c_collision.get_other_component(IComponent.ComponentName.C_STATUS_LIST)

	var nums_infos = c_status.numinfo_list

	var effective_damage = 0
	for hit_effect:IHitEffect in hit_effect_list:
		if hit_effect is StatusEffect:
			if hit_effect.status_effect_target == SoraConstant.StatusEnum.Health:
				effective_damage = -hit_effect.status_effect_value
				effective_damage -= nums_infos.get(SoraConstant.StatusEnum.DefendPoint, 0)
		elif hit_effect is BuffEffect:
			pass
		elif hit_effect is CountedEffect:
			pass
	return max(1, effective_damage)

func _hurted_animation():
	var c_texture_controller: CTextureController = c_collision.get_other_component(IComponent.ComponentName.C_TEXTURE_CONTROLLER)
	c_texture_controller.packed_sprite.packed_sprite_editor.受伤()

func _hurted_particle(hitbox: IHitbox):
	var hitbox_position = hitbox.global_position
	var hitbox_direction = hitbox.c_collision.get_value("start_direction", Vector2.RIGHT)
	
	var effect_marker: EffectMarker = c_collision.box_markers.get(CCollisionBox.BoxMarkerType.EFFECT)
	if effect_marker:
		effect_marker.hurted_effect(hitbox_position, -hitbox_direction)

func _hurted_decal(hitbox: IHitbox):
	var hitbox_direction = hitbox.c_collision.get_value("start_direction", Vector2.RIGHT)
	var decal_range = randi_range(50, 100)
	var context = {"start_direction": hitbox_direction, "target_range": decal_range}

	SObjectPool._spawn("decal", null, context, hitbox.global_position)
	
