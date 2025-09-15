## 受伤判定盒 - 处理伤害接收和防御计算
## 接收来自IHitbox的攻击并计算实际伤害，支持防御计算和特效触发
## 用于玩家角色、敌人单位、可破坏物等伤害处理
## [br][b]编辑者:[/b] Sora
@tool
class_name Hurtbox
extends BoxCollision

## 受伤特效行为
var hurt_effect
## 受伤粒子效果
var hurt_particle

## 受伤信号
## 当实体受到伤害时发出
## [param hit_damage]: 实际受到的伤害值
signal hurted(hitbox: IHitbox, hit_damage: int)

## 状态组件引用
## 获取和更新实体的状态信息
@export var c_status: CStatusList
@export var c_texture_controller: CTextureController

func _enter_tree() -> void:
	box_collision_name = CCollisionBox.BoxCollisionName.HURT
	collision_layer = Main.PhysicsLayer.Breakable
	collision_mask = Main.PhysicsLayer.Breakable

## 连接碰撞检测和伤害处理信号
func _ready() -> void:
	# 连接区域进入信号
	area_entered.connect(_on_area_entered)
	# 连接受伤处理信号
	hurted.connect(_on_hurted)

## 当IHitbox进入受伤范围时处理
## [param area]: 进入的碰撞区域
func _on_area_entered(area: Area2D):
	# 检查是否为HitBox
	if area is IHitbox:
		var hitbox = area
		# 验证攻击类型匹配
			
		# 计算伤害值
		var damage = _calculate_hit(hitbox)
		if damage > 0:
			hurted.emit(area, damage)

## 处理实际的伤害应用和特效触发
## [param hit_damage]: 受到的伤害值
func _on_hurted(hitbox: IHitbox,hit_damage: int):
	# 应用伤害到生命值
	if c_status and c_status.status_list.has(SoraConstant.StatusEnum.Health):
		c_status.status_list[SoraConstant.StatusEnum.Health].value -= hit_damage
	else:
		push_error("实体", c_status.component_owner.name, "不存在健康状态")
	
	# 触发受伤特效
	_hurted_animation()
	_hurted_particle(hitbox)
	_hurted_decal(hitbox)

	print("实体受伤: ", hit_damage, " 点伤害", )

## 结合攻击力和防御力计算最终伤害
## [param hitbox]: 攻击判定盒
func _calculate_hit(hitbox: IHitbox) -> int:
	var hit_effect_list: Array[IHitEffect] = hitbox.get_hit_effect()

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
	# 计算最终伤害（基础伤害 - 防御力，最小为1）
	return max(1, effective_damage)

## 受伤动画
func _hurted_animation():
	c_texture_controller.packed_sprite.packed_sprite_editor.受伤()
	pass

## 受伤粒子效果
func _hurted_particle(hitbox: IHitbox):
	var hitbox_position = hitbox.global_position
	var hitbox_direction = hitbox.c_collision.get_blackboard().get_value("start_direction", Vector2.RIGHT, true)
	
	var effect_marker: EffectMarker = c_collision.box_markers.get(CCollisionBox.BoxMarkerType.EFFECT)
	if effect_marker:
		effect_marker.hurted_effect(hitbox_position, -hitbox_direction)

func _hurted_decal(hitbox: IHitbox):
	var hitbox_direction = hitbox.c_collision.get_blackboard().get_value("start_direction", Vector2.RIGHT, true)
	var decal_range = randi_range(50, 100)
	var context = {"start_direction": hitbox_direction, "target_range": decal_range}

	SObjectPool._spawn("decal", null, context, hitbox.global_position)
	