## @editing: Sora [br]
## @describe: 用于可受伤的实体，与HitBox进行对接，计算来自目标的伤害并作用于Status组件
class_name Hurtbox
extends BoxCollision

signal hurted(hit_damage: int)

@export var hitbox_type: PackedStringArray
@export var c_status: C_Status

@export var hurt_effect: Action

#func _ready() -> void:
	#area_entered.connect(_on_area_entered)
	#hurted.connect(_on_hurted)
#
#
### FIXME 过时的代码, 需要进行修正
#func _on_area_entered(area: Area2D):
	#if area.get_parent() is Hitbox:
		#if hitbox_type.size() == 0 || hitbox_type.has(area.equipment.current_tool):
			#var num_infos = area.status.numinfo_list
			#if num_infos.has(SoraConstant.StatusEnum.AttackPoint):
				#hurted.emit(area.status.numinfo_list[SoraConstant.StatusEnum.AttackPoint].value)
			#
#
#func _on_hurted(hit_damage: int):
	#c_status.status_list[SoraConstant.StatusEnum.Health].value -= hit_damage
	#if (hurt_effect != null):
		#hurt_effect._effect()
	
