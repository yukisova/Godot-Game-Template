## 受伤判定盒 - 处理伤害接收和防御计算
## 接收来自IHitbox的攻击并计算实际伤害，支持防御计算和特效触发
## 用于玩家角色、敌人单位、可破坏物等伤害处理
## [br][b]编辑者:[/b] Sora
class_name Hurtbox
extends BoxCollision

## 受伤信号
## 当实体受到伤害时发出
## [param hit_damage]: 实际受到的伤害值
signal hurted(hit_damage: int)

## 状态组件引用
## 获取和更新实体的状态信息
@export var c_status: CStatusList

## 受伤特效行为
## 受到伤害时执行的特效
@export var hurt_effect: IAction

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
			hurted.emit(damage)

## 处理实际的伤害应用和特效触发
## [param hit_damage]: 受到的伤害值
func _on_hurted(hit_damage: int):
	# 应用伤害到生命值
	if c_status and c_status.status_list.has(SoraConstant.StatusEnum.Health):
		c_status.status_list[SoraConstant.StatusEnum.Health].value -= hit_damage
	else:
		push_error("实体", c_status.component_owner.name, "不存在健康状态")
	
	# 触发受伤特效
	if hurt_effect != null:
		hurt_effect._trigger_update()
	
	SoraEvent.camera_shake(self, 3)
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
