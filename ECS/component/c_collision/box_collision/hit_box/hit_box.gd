## @editing: Sora [br]
## @describe: 用于子弹或近战，与目标实体的HurtBox进行对接，对目标造成伤害
class_name Hitbox
extends BoxCollision

@export var equipment: StatusEquipment
@export var status: C_Status
var collision: CollisionShape2D
