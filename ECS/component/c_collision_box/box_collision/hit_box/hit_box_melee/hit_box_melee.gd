## 近战攻击判定盒 - 实现近战武器的攻击判定
## 检测近战攻击命中并计算伤害，基于角色状态和装备信息
## 支持剑、斧、锤等各种近战武器的攻击判定
## [br][b]编辑者:[/b] Sora
@tool
class_name HitboxMelee
extends IHitbox

## 从黑板获取动态攻击效果列表
func get_hit_effect() -> Array[IHitEffect]:
	if hit_effects.is_empty():
		var effects = c_status.get_value("hit_effects", [])
		var result:Array[IHitEffect] = []
	
		# 确保数组中的每个元素都是 IHitEffect 类型
		for effect in effects:
			if effect is IHitEffect:
				result.append(effect)
		return result as Array[IHitEffect]
	else:
		return hit_effects

func _validate_property(property: Dictionary) -> void:
	if property.name == "status":
		property.usage = PROPERTY_USAGE_NO_EDITOR
