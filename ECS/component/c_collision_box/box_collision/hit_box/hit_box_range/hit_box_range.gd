## 远程攻击判定盒 - 实现远程武器的攻击判定和伤害计算
## 
## 该类实现了远程攻击判定系统，用于检测远程攻击是否命中目标并计算伤害。
## 当HitBox与目标的HurtBox发生碰撞时，会根据子弹实体的数据计算并造成伤害。
## 
## 核心功能：
## - 基于子弹实体的动态伤害计算
## - 精确的碰撞检测和判定
## - 灵活的攻击范围控制
## - 与远程武器系统的无缝集成
## 
## 远程攻击特性：
## - [b]伤害计算[/b]：基于子弹实体的 [ContainerBlackboard] 数据进行最终伤害计算（由 [WeaponAttackNode] 传入）
## - [b]碰撞检测[/b]：与目标实体的HurtBox进行精确碰撞检测
## - [b]攻击范围[/b]：完全依赖于子弹实体的逻辑，根据需要动态变化
## 
## 数据流程：
## 1. [WeaponAttackNode] 创建子弹实体
## 2. 子弹携带攻击数据到 [ContainerBlackboard]
## 3. HitBox从黑板获取攻击效果列表
## 4. 碰撞时应用效果到目标实体
## 
## 应用场景：
## - 子弹、箭矢等抛射物攻击
## - 激光、魔法弹等能量武器
## - 手雷、炸弹等爆炸武器
## - 陷阱、地雷等延时攻击
## 
## 架构设计：
## - 继承自 [IHitbox] 基类
## - 使用 [annotation @tool] 支持编辑器功能
## - 基于黑板的数据获取机制
## - 与子弹实体系统的集成
##
## [br][b]编辑者:[/b] Sora
@tool
class_name HitboxRange
extends IHitbox

## 获取攻击效果列表（重写方法）
## 
## 从子弹实体的黑板中获取攻击效果数据。
## [br][br][b]返回:[/b] [Array] of [IHitEffect] 攻击效果列表
func get_hit_effect() -> Array[IHitEffect]:
	var blackboard = c_collision.get_blackboard()
	var result = blackboard.get_value("hit_effect_list", [])
	return result as Array[IHitEffect]
