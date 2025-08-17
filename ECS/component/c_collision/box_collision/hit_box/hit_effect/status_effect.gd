## 状态效果 - 实现对目标实体状态值的直接修改
##
## 该类实现了状态效果系统，能够对目标实体的各种状态值进行精确的数值操作。
## 支持增减运算和直接赋值两种操作模式，适用于伤害、治疗、状态调整等场景。
##
## 核心功能：
## - 多种状态值的操作支持
## - 灵活的数值计算模式
## - 安全的数值边界检查
## - 与状态系统的无缝集成
##
## 操作模式：
## - [b]PLUS[/b]：对目标状态值进行加减运算
## - [b]CHANGED[/b]：直接将状态值设置为指定数值
##
## 支持的状态类型：
## - 生命值、法力值、体力值
## - 攻击力、防御力、速度
## - 各种自定义状态属性
##
## 数值验证：
## - 自动过滤无效的状态类型
## - 负数处理和边界保护
## - 类型匹配的安全检查
##
## 应用场景：
## - 武器攻击造成的伤害
## - 药水治疗的恢复效果
## - 装备属性的数值加成
## - 技能效果的状态修改
## - 环境因素的状态影响
##
## 架构设计：
## - 继承自 [IHitEffect] 基类
## - 使用 [annotation @tool] 支持编辑器功能
## - 基于枚举的操作类型管理
## - 集成 [SoraConstant.StatusEnum] 状态系统
##
## [br][b]编辑者:[/b] Sora
@tool
class_name StatusEffect
extends IHitEffect

## 状态效果操作类型
##
## 定义对状态值的操作方式。
enum StatusEffectType {
    PLUS,    ## 加减运算
    CHANGED, ## 直接赋值
}

## 状态效果操作类型
## 
## 指定对状态值的操作方式，类型为 [enum StatusEffectType]。
@export var status_effect_type: StatusEffectType

## 状态效果目标
## 
## 要修改的状态类型，类型为 [SoraConstant.StatusEnum]。
## [br][b]注意:[/b] 自动过滤不支持的状态类型（/100 > 0的值）。
@export var status_effect_target: SoraConstant.StatusEnum:
    set(value):
        if value / 100 > 0:
            return
        status_effect_target = value

## 状态效果数值
## 
## 应用到状态的数值，根据操作类型进行不同的处理。
@export var status_effect_value: int:
    set(value):
        match status_effect_type:
            StatusEffectType.PLUS:
                status_effect_value = value
            StatusEffectType.CHANGED:
                if value < 0:
                    status_effect_value = 0

