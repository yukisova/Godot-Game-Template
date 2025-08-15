## @editing: Sora [br]
## @describe: 受伤判定盒 - 处理伤害接收和防御计算的碰撞区域
## 
## 该类实现了游戏中的受伤判定系统，用于接收来自HitBox的攻击并计算实际受到的伤害。
## 支持不同类型的攻击过滤、防御力计算、以及受伤后的特效处理。
## 
## 受伤系统特性：
## - 伤害接收：接收来自HitBox的攻击伤害
## - 类型过滤：可配置接受特定类型的攻击（如物理、魔法等）
## - 防御计算：结合实体防御力计算最终受到的伤害
## - 状态更新：自动更新实体的生命值等状态信息
## - 特效触发：受伤时可触发特定的视觉或音效
## 
## 伤害处理流程：
## 1. 检测来自HitBox的攻击
## 2. 验证攻击类型是否匹配
## 3. 计算防御后的实际伤害
## 4. 更新实体生命值等状态
## 5. 触发受伤特效和反馈
## 
## 应用场景：
## - 玩家角色：处理玩家受到的各种伤害
## - 敌人单位：处理敌人的受伤和死亡
## - 可破坏物：处理环境物体的损坏
## - 载具系统：处理载具的耐久度损失
## - 建筑物：处理建筑物的破坏判定
## 
class_name Hurtbox
extends BoxCollision

## 受伤信号
## 当实体受到伤害时发出，传递实际伤害数值
## @param hit_damage: 实际受到的伤害值
signal hurted(hit_damage: int)

## 接受的攻击类型
## 定义此受伤盒可以接受的攻击类型（如物理、魔法、火焰等）
## 空数组表示接受所有类型的攻击
@export var hitbox_effect_type: PackedStringArray

## 状态组件引用
## 用于获取和更新实体的生命值、防御力等状态信息
@export var c_status: CStatus

## 受伤特效行为
## 受到伤害时执行的特效或反馈行为
@export var hurt_effect: Action

func _enter_tree() -> void:
	box_collision_name = CCollision.BoxCollisionName.HURT

## 初始化受伤系统
## 连接碰撞检测和伤害处理信号
## TODO: 需要重新实现以适配新的系统架构
func _ready() -> void:
	# 连接区域进入信号
	area_entered.connect(_on_area_entered)
	# 连接受伤处理信号
	hurted.connect(_on_hurted)

## 碰撞区域进入处理
## 当HitBox进入受伤范围时触发
## @param area: 进入的碰撞区域
func _on_area_entered(area: Area2D):
	# 检查是否为HitBox
	if area is IHitbox:
		var hitbox = area
		# 验证攻击类型匹配
		if hitbox_effect_type.size() == 0 or _is_attack_type_valid(hitbox):
			# 计算伤害值
			var damage = _calculate_damage(hitbox)
			if damage > 0:
				hurted.emit(damage)

## 受伤处理
## 处理实际的伤害应用和特效触发
## @param hit_damage: 受到的伤害值
func _on_hurted(hit_damage: int):
	# 应用伤害到生命值
	if c_status and c_status.status_list.has(SoraConstant.StatusEnum.Health):
		c_status.status_list[SoraConstant.StatusEnum.Health].value -= hit_damage
	
	# 触发受伤特效
	if hurt_effect != null:
		hurt_effect._effect()
	
	print("实体受伤: ", hit_damage, " 点伤害")

## 验证攻击类型是否有效
## @param _hitbox: 攻击判定盒
## @return: 是否为有效的攻击类型
func _is_attack_type_valid(_hitbox: IHitbox) -> bool:
	# TODO: 实现具体的攻击类型验证逻辑
	# 可以检查武器类型、元素类型等
	return true

## 计算实际伤害
## 结合攻击力和防御力计算最终伤害
## @param hitbox: 攻击判定盒
## @return: 计算后的伤害值
func _calculate_damage(hitbox: IHitbox) -> int:
	var base_damage = 0
	
	# 获取攻击力
	if hitbox.status and hitbox.status.numinfo_list.has(SoraConstant.StatusEnum.AttackPoint):
		base_damage = hitbox.status.numinfo_list[SoraConstant.StatusEnum.AttackPoint].value
	
	# 获取防御力
	var defense = 0
	if c_status and c_status.numinfo_list.has(SoraConstant.StatusEnum.DefendPoint):
		defense = c_status.numinfo_list[SoraConstant.StatusEnum.DefendPoint].value
	
	# 计算最终伤害（基础伤害 - 防御力，最小为1）
	return max(1, base_damage - defense)
