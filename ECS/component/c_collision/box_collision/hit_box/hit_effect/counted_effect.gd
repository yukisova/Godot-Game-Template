class_name CountedEffect
extends IHitEffect

@export var counted_buff: IBuff
@export var counted_effect_value: int:
    set(value):
        if value < -100:
            counted_effect_value = -100
        elif value > 100:
            counted_effect_value = 100
        else:
            counted_effect_value = value