## 近战攻击判定盒 - 实现近战武器的攻击判定
## 检测近战攻击命中并计算伤害，基于角色状态和装备信息
## 支持剑、斧、锤等各种近战武器的攻击判定
## [br][b]编辑者:[/b] Sora
@tool
class_name HitboxMelee
extends IHitbox

## 攻击效果列表
## 近战武器的攻击效果配置
@export var hit_effect_list: Array[IHitEffect]

## 从黑板获取动态攻击效果列表
func get_hit_effect() -> Array[IHitEffect]:
	var blackboard = c_collision.get_blackboard()
	var result = blackboard.get_value("hit_effect_list", [])
	return result as Array[IHitEffect]
