@tool
class_name StatusEffect
extends IHitEffect

enum StatusEffectType {
    PLUS, ## 加减运算
    CHANGED, ## 直接赋值
}

@export var status_effect_type: StatusEffectType
@export var status_effect_target: SoraConstant.StatusEnum:
    set(value):
        if value / 100 > 0:
            return
        status_effect_target = value
@export var status_effect_value: int:
    set(value):
        match status_effect_type:
            StatusEffectType.PLUS:
                status_effect_value = value
            StatusEffectType.CHANGED:
                if value < 0:
                    status_effect_value = 0

