## 死亡后尸体掉落
extends Action

@export var drop_item:  PackedScene
@export var c_status: C_Status

func _ready() -> void:
	c_status.status_overred.connect(_effect)

func _effect(..._args):
	if _args[0] == SoraConstant.StatusEnum.Health:
		var item = drop_item.instantiate() as Entity
		Main.s_map_data.emit_signal("factor_added", item, c_action.component_owner.main_control.global_position)
	
