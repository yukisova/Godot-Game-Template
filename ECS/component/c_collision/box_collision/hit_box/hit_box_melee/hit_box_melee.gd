## @editing: Sora [br]
## @describe: 近战攻击判定盒
## 
## 该类实现了近战攻击判定系统，用于检测近战攻击是否命中目标并计算伤害。
## 当HitBox与目标的HurtBox发生碰撞时，会根据装备和状态信息计算并造成伤害。
## 
## 近战攻击系统特性：
## - 伤害计算：基于角色的status和装备的attack_node计算输出伤害
## - 攻击范围：基于装备的attack_node计算攻击范围，并会随着玩家的位移而移动
## - 装备集成：支持不同武器和装备的攻击属性
@tool
class_name HitboxMelee
extends IHitbox

@export var hit_effect_list: Array[IHitEffect]

func get_hit_effect() -> Array[IHitEffect]:
    var blackboard = c_collision.get_blackboard()
    var result = blackboard.get_value("hit_effect_list", [])
    return result as Array[IHitEffect]