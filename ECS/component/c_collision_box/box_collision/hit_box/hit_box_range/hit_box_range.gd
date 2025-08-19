## 远程攻击判定盒 - 实现远程武器的攻击判定
## 基于子弹实体的动态伤害计算，精确的碰撞检测
## 支持子弹、箭矢等抛射物和激光等能量武器
## [br][b]编辑者:[/b] Sora
@tool
class_name HitboxRange
extends IHitbox

## 从子弹实体黑板获取攻击效果数据
func get_hit_effect() -> Array[IHitEffect]:
	var blackboard = c_collision.get_blackboard()
	var result = blackboard.get_value("hit_effect_list", [])
	return result as Array[IHitEffect]
