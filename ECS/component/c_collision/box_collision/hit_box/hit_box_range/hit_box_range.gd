## @describe: 远程攻击判定盒
## 
## 该类实现了远程攻击判定系统，用于检测远程攻击是否命中目标并计算伤害。
## 当HitBox与目标的HurtBox发生碰撞时，会根据装备和状态信息计算并造成伤害。
## 
## 远程攻击系统特性：
## - 伤害计算：基于子弹实体的container_blackboard数据进行最终伤害的计算（由attack_node传入）
## - 碰撞检测：与目标实体的HurtBox进行精确碰撞检测
## - 攻击范围：完全依赖于子弹实体的逻辑, 根据需要进行变化
class_name HitboxRange
extends IHitbox
