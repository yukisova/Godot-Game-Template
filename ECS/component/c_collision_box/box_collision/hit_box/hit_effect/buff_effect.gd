## Buff效果 - 对目标实体Buff状态的管理和操作
## 支持Buff的延长、缩短、等级调整等操作模式
## 包括PLUS、MINUS、LEVEL三种操作类型
## [br][b]编辑者:[/b] Sora
@tool
class_name BuffEffect
extends IHitEffect

## Buff效果操作类型
## 定义对Buff的操作方式
enum BuffEffectType {
    PLUS,  ## 延长时间或增加层数
    MINUS, ## 缩短时间或减少层数
    LEVEL, ## 调整Buff等级
}

## Buff效果操作类型
## 指定对Buff的操作方式
@export var buff_effect_type: BuffEffectType

## 目标Buff
## 要操作的Buff资源
@export var buff: IBuff

## Buff效果数值
## 应用到Buff的数值
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