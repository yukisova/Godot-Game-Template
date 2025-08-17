## 近战攻击判定盒 - 实现近战武器的攻击判定和伤害计算
## 
## 该类实现了近战攻击判定系统，用于检测近战攻击是否命中目标并计算伤害。
## 当HitBox与目标的HurtBox发生碰撞时，会根据角色状态和装备信息计算并造成伤害。
## 
## 核心功能：
## - 基于角色状态的动态伤害计算
## - 跟随玩家移动的攻击范围
## - 装备属性的无缝集成
## - 多种近战武器的支持
## 
## 近战攻击特性：
## - [b]伤害计算[/b]：基于角色的 [CStatus] 和装备的 [WeaponAttackNode] 计算输出伤害
## - [b]攻击范围[/b]：基于装备的 [WeaponAttackNode] 计算攻击范围，随着玩家位移而移动
## - [b]装备集成[/b]：支持不同武器和装备的攻击属性配置
## 
## 数据来源：
## - 角色状态：从 [CStatus] 获取基础攻击力
## - 武器属性：从 [WeaponAttackNode] 获取武器加成
## - 攻击效果：可配置的攻击效果列表
## - 黑板数据：运行时的临时攻击数据
## 
## 应用场景：
## - 剑、斧、锤等近战武器
## - 拳套、爪子等格斗武器
## - 法杖、魔导器等魔法武器
## - 工具类武器的攻击判定
## 
## 架构设计：
## - 继承自 [IHitbox] 基类
## - 使用 [annotation @tool] 支持编辑器功能
## - 支持直接配置的攻击效果列表
## - 与角色装备系统的深度集成
##
## [br][b]编辑者:[/b] Sora
@tool
class_name HitboxMelee
extends IHitbox

## 攻击效果列表
## 
## 近战武器的攻击效果配置，类型为 [Array] of [IHitEffect]。
@export var hit_effect_list: Array[IHitEffect]

## 获取攻击效果列表（重写方法）
## 
## 优先从黑板获取动态攻击效果，如果没有则使用配置的效果列表。
## [br][br][b]返回:[/b] [Array] of [IHitEffect] 攻击效果列表
func get_hit_effect() -> Array[IHitEffect]:
    var blackboard = c_collision.get_blackboard()
    var result = blackboard.get_value("hit_effect_list", [])
    return result as Array[IHitEffect]