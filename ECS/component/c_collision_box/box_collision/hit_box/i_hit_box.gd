## 攻击判定盒基类 - 处理伤害输出和攻击检测
## 检测攻击命中目标并计算伤害，支持不同类型的攻击效果
## 与装备系统和状态系统集成，处理近战远程等各种攻击
## [br][b]编辑者:[/b] Sora
@tool
@abstract class_name IHitbox
extends BoxCollision

## 攻击效果类型枚举
## 定义攻击对目标造成的效果类型
enum HitEffectType {
	STATUS,    ## 动态状态变化
	BUFF,      ## 持续性效果
	COUNTED    ## 临时属性点累积
}

## 状态组件引用
## 获取实体的战斗属性
@export var c_status: CStatusList

@export var hit_effects: Array[IHitEffect] = []

## 碰撞形状组件
## 定义攻击判定的范围和形状
var collision: CollisionShape2D

func _enter_tree() -> void:
	box_collision_name = CCollisionBox.BoxCollisionName.HIT
	collision_layer = Main.PhysicsLayer.Breakable
	collision_mask = Main.PhysicsLayer.Wall | Main.PhysicsLayer.Breakable

## 获取攻击效果数组
func get_hit_effect() -> Array[IHitEffect]:
	return hit_effects

func _initialize():
	pass
