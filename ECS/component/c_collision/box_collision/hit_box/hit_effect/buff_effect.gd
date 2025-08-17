## Buff效果 - 实现对目标实体Buff状态的管理和操作
##
## 该类实现了Buff效果系统，能够对目标实体的Buff状态进行时间、等级等属性的精确控制。
## 支持Buff的延长、缩短、等级调整等多种操作模式。
##
## 核心功能：
## - 灵活的Buff时间管理
## - 精确的Buff等级控制
## - 安全的数值范围检查
## - 与Buff系统的深度集成
##
## 操作模式：
## - [b]PLUS[/b]：延长Buff持续时间或增加层数
## - [b]MINUS[/b]：缩短Buff持续时间或减少层数
## - [b]LEVEL[/b]：调整Buff的等级强度（0-3级）
##
## Buff管理特性：
## - 时间叠加和刷新机制
## - 等级提升和降低控制
## - Buff清除和移除功能
## - 多层Buff的智能管理
##
## 数值验证：
## - 等级范围限制（0-3级）
## - 负数处理的特殊逻辑
## - 类型匹配的安全检查
##
## 应用场景：
## - 技能释放的Buff效果
## - 装备加成的持续增益
## - 药水效果的状态强化
## - 环境因素的Buff影响
## - 敌人攻击的Debuff效果
##
## 架构设计：
## - 继承自 [IHitEffect] 基类
## - 使用 [annotation @tool] 支持编辑器功能
## - 基于枚举的操作类型管理
## - 集成 [IBuff] Buff资源系统
##
## [br][b]编辑者:[/b] Sora
@tool
class_name BuffEffect
extends IHitEffect

## Buff效果操作类型
##
## 定义对Buff的操作方式。
enum BuffEffectType {
    PLUS,  ## 加减运算（延长时间或增加层数）
    MINUS, ## 减少运算（缩短时间或减少层数）
    LEVEL, ## 等级运算（调整Buff等级）
}

## Buff效果操作类型
## 
## 指定对Buff的操作方式，类型为 [enum BuffEffectType]。
@export var buff_effect_type: BuffEffectType

## 目标Buff
## 
## 要操作的Buff资源，类型为 [IBuff]。
@export var buff: IBuff

## Buff效果数值
## 
## 应用到Buff的数值，根据操作类型进行不同的处理和验证。
@export var buff_effect_value: int:
    set(value):
        match buff_effect_type:
            BuffEffectType.PLUS:
                buff_effect_value = value
            BuffEffectType.MINUS:
                buff_effect_value = value
            BuffEffectType.LEVEL:
                if value < 0:
                    buff_effect_value = 0
                elif value > 3:
                    buff_effect_value = 3
                else:
                    buff_effect_value = value