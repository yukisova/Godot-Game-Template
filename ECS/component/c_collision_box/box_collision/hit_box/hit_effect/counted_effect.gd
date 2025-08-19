## 计数效果 - 累积触发机制的攻击效果
## 通过累积数值触发特殊Buff效果，类似诅咒机制
## 支持数值累积和阈值触发功能
## [br][b]编辑者:[/b] Sora
class_name CountedEffect
extends IHitEffect

## 计数Buff
## 达到阈值时触发的Buff效果
@export var counted_buff: IBuff

## 计数效果数值
## 每次应用的计数增量，范围-100到+100
@export var counted_effect_value: int:
    set(value):
        if value < -100:
            counted_effect_value = -100
        elif value > 100:
            counted_effect_value = 100
        else:
            counted_effect_value = value