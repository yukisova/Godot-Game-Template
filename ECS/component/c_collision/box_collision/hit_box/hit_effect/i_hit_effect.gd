## @editing: Sora [br]
## @describe: 攻击效果
## 
## 该类实现了攻击效果的定义和验证。
## 攻击效果可以分为以下几种类型， 每个类型又有不同的操作：
## - STATUS: 目标的动态状态变化，比如血量下降，或者法力值消耗，等等
##  - PLUS：指定状态的存在
##  - CHANGED：比如血量变化，法力值变化，等等， 需要指定变化的数值
## - BUFF: 持续性效果，比如buff，debuff，护盾，等等
##  - PLUS: 如果目标BUFF已经存在，则叠加目标BUFF的时间, 若指定为负数则直接刷新目标BUFF
##  - MINUS: 如果目标BUFF已经存在，则缩短目标BUFF的时间，若指定为负数则直接清除目标BUFF
##  - LEVEL: 如果目标BUFF已经存在，则提升目标BUFF的等级，若指定为负数则降低目标BUFF的等级
## - COUNTED: 增加临时属性点，当到达了临界值后，会自动触发效果（可以类比一下黑暗之魂的诅咒点，当累计到一定程度后， 角色会即死）
##  - PLUS：比如血量上升，法力值上升，等等， 需要指定上升的数值
@abstract class_name IHitEffect
extends Resource

