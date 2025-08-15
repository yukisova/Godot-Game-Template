@tool
class_name BuffEffect
extends IHitEffect

enum BuffEffectType {
    PLUS, ## 加减运算
    MINUS, ## 
    LEVEL, ## 等级运算
}

@export var buff_effect_type: BuffEffectType
@export var buff: IBuff
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