## 远程攻击判定盒 - 实现远程武器的攻击判定
## 基于子弹实体的动态伤害计算，精确的碰撞检测
## 支持子弹、箭矢等抛射物和激光等能量武器
## [br][b]编辑者:[/b] Sora
@tool
class_name HitboxRange
extends IHitbox

## 最大命中高度，超过该高度则不进行命中判定，该参数用于处理抛物线移动的子弹，
@export var max_hit_height: float = 0.0
@export var move_strategy: IUpdateAction

## 从子弹实体黑板获取攻击效果数据
func get_hit_effect() -> Array[IHitEffect]:
	var blackboard = c_collision.get_blackboard()
	var effects = blackboard.get_value("hit_effect_list", [])
	var result:Array[IHitEffect] = []
	
	# 确保数组中的每个元素都是 IHitEffect 类型
	for effect in effects:
		if effect is IHitEffect:
			result.append(effect)
	
	return result

func _update(_delta: float):
	if move_strategy.get_current_height() > max_hit_height:
		monitorable = false
		monitoring = false
		for i in get_children():
			if i is CollisionPolygon2D or i is CollisionShape2D:
				i.debug_color = Color.BLUE_VIOLET
				i.debug_color.a = 0.5
	else:
		monitorable = true
		monitoring = true
		for i in get_children():
			if i is CollisionPolygon2D or i is CollisionShape2D:
				i.debug_color = Color.YELLOW
				i.debug_color.a = 0.5
