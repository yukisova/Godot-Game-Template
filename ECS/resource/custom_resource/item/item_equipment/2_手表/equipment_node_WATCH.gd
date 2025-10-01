## 表的装备节点
@tool
extends EquipmentNode

## 在装备了表之后，在白板HUD中添加的因子
@export var factor_control: PackedScene
var factor_control_instance: Control

func _activated():
	factor_control_instance = factor_control.instantiate()
	SUiSpawner.hud_whiteboard.add_factor(factor_control_instance, 3)

func _deactivated():
	SUiSpawner.hud_whiteboard.remove_factor(factor_control_instance)
