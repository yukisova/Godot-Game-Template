## 状态效果 - 对目标实体状态值的直接修改
## 支持增减运算和直接赋值，适用于伤害治疗等场景
## 包括PLUS和CHANGED两种操作模式
## [br][b]编辑者:[/b] Sora
@tool
class_name StatusEffect
extends IHitEffect

## 状态效果操作类型
## 定义对状态值的操作方式
enum StatusEffectType {
    PLUS,    ## 加减运算
    CHANGED, ## 直接赋值
}

## 状态效果操作类型
## 指定对状态值的操作方式
@export var status_effect_type: StatusEffectType

## 状态效果目标
## 要修改的状态类型
@export var status_effect_target: SoraConstant.StatusEnum:
    set(value):
        if value / 100 > 0:
            return
        status_effect_target = value

## 状态效果数值
## 应用到状态的数值
@export var status_effect_value: int:
    set(value):
        match status_effect_type:
            StatusEffectType.PLUS:
                status_effect_value = value
            StatusEffectType.CHANGED:
                if value < 0:
                    status_effect_value = 0

