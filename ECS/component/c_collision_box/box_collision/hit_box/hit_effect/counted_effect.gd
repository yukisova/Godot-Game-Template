## 计数效果 - 实现累积触发机制的攻击效果
##
## 该类实现了计数效果系统，通过累积数值来触发特殊的Buff效果。
## 类似于黑暗之魂的诅咒机制，当累积值达到特定阈值时触发强力效果。
##
## 核心功能：
## - 数值累积的触发机制
## - 安全的数值范围控制
## - 与Buff系统的深度集成
## - 阈值达成的自动处理
##
## 计数机制：
## - 每次攻击增加计数值
## - 达到阈值时触发关联的Buff
## - 支持正负值的累积逻辑
## - 自动重置和循环机制
##
## 数值验证：
## - 范围限制：-100 到 +100
## - 边界保护：超出范围时自动调整
## - 类型安全：确保数值的有效性
##
## 应用场景：
## - 中毒累积：多次中毒达到致命阈值
## - 诅咒效果：负面状态的累积触发
## - 能量充能：正面效果的累积激活
## - 连击系统：连续攻击的奖励机制
## - 疲劳系统：持续行动的负面累积
##
## 架构设计：
## - 继承自 [IHitEffect] 基类
## - 集成 [IBuff] Buff资源系统
## - 基于数值范围的安全检查
## - 支持自定义的触发逻辑
##
## [br][b]编辑者:[/b] Sora
class_name CountedEffect
extends IHitEffect

## 计数Buff
## 
## 达到阈值时触发的Buff效果，类型为 [IBuff]。
@export var counted_buff: IBuff

## 计数效果数值
## 
## 每次应用的计数增量，范围限制在-100到+100之间。
@export var counted_effect_value: int:
    set(value):
        if value < -100:
            counted_effect_value = -100
        elif value > 100:
            counted_effect_value = 100
        else:
            counted_effect_value = value