## HurtBox
extends Area2D

signal hurted(hit_damage: int)

@export var hitbox_type: PackedStringArray
@export var c_status: C_Status

@export var hurt_effect: Action

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	hurted.connect(_on_hurted)


func _on_area_entered(area: Area2D):
	if area is Hitbox:
		if hitbox_type.size() == 0 || hitbox_type.has(area.equipment.current_tool):
			var numinfos = area.status.numinfo_list
			if numinfos.has(SoraConstant.StatusEnum.AttackPoint):
				hurted.emit(area.status.numinfo_list[SoraConstant.StatusEnum.AttackPoint].value)
			

func _on_hurted(hit_damage: int):
	c_status.status_list[SoraConstant.StatusEnum.Health].value -= hit_damage
	if (hurt_effect != null):
		hurt_effect._effect()
	
