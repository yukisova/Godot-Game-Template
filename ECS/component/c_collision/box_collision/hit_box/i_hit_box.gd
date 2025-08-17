## 攻击判定盒基类 - 处理伤害输出和攻击检测的碰撞区域
##
## 该抽象类实现了游戏中的攻击判定系统，用于检测攻击是否命中目标并计算伤害。
## 当 [IHitbox] 与目标的 [Hurtbox] 发生碰撞时，会根据装备和状态信息计算并造成伤害。
##
## 攻击系统特性：
## - 伤害计算：基于装备属性和状态值计算输出伤害
## - 碰撞检测：与目标实体的 [Hurtbox] 进行精确碰撞检测
## - 装备集成：支持不同武器和装备的攻击属性
## - 状态关联：与实体状态系统集成，获取攻击力等属性
##
## 伤害计算流程：
## 1. 检测与 [Hurtbox] 的碰撞
## 2. 获取当前装备的攻击属性
## 3. 结合实体状态计算最终伤害
## 4. 将伤害信息传递给目标的 [Hurtbox]
##
## 应用场景：
## - 近战攻击：剑、斧等近战武器的攻击判定
## - 远程攻击：子弹、箭矢等投射物的伤害判定
## - 魔法攻击：法术效果的伤害区域判定
## - 陷阱伤害：地刺、爆炸等环境伤害判定
## - AOE技能：范围攻击技能的伤害判定
##
## 架构设计：
## - 抽象基类，继承自 [BoxCollision]
## - 基于 [enum HitEffectType] 的攻击效果类型
## - 与 [EquipmentExtension] 和 [CStatus] 集成
## - 通过 [IHitEffect] 数组传递攻击效果
##
## [br][b]编辑者:[/b] Sora
@abstract class_name IHitbox
extends BoxCollision

## 攻击效果类型枚举
## 
## 列举攻击所会对目标造成的效果类型。
enum HitEffectType {
	STATUS,    ## 动态状态变化 - 比如血量下降，或者法力值消耗等
	BUFF,      ## 持续性效果 - 比如buff、debuff、护盾等
	COUNTED    ## 增加临时属性点 - 当到达临界值后，会自动触发效果（类比黑暗之魂的诅咒点）
}

## 装备组件引用
## 
## 用于获取当前装备的攻击属性和伤害加成，类型为 [EquipmentExtension]。
@export var equipment_extension: EquipmentExtension

## 状态组件引用
## 
## 用于获取实体的攻击力、暴击率等战斗属性，类型为 [CStatus]。
@export var status: CStatus

## 碰撞形状组件
## 
## 定义攻击判定的具体范围和形状，类型为 [CollisionShape2D]。
var collision: CollisionShape2D

func _enter_tree() -> void:
	box_collision_name = CCollision.BoxCollisionName.HIT
	collision_layer = Main.PhysicsLayer.Breakable
	collision_mask = Main.PhysicsLayer.Wall | Main.PhysicsLayer.Breakable

## 获取攻击效果（抽象方法）
## 
## 由 [Hurtbox] 调用，用于计算伤害与可能施加给目标的buff。
## [br][br][b]返回:[/b] [Array] 攻击效果数组，包含所有 [IHitEffect] 效果
func get_hit_effect() -> Array[IHitEffect]:
	return []
