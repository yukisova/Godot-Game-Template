##@editing:	Sora
##@describe:	死亡后尸体掉落物品(所谓的物品本身应为实体，具体的数据依靠相关的Resource类进行初始化)
extends Action

@export var drop_item: PackedScene
@export var c_status: C_Status
@export var drop_item_data: Item

func _ready() -> void:
	c_status.status_overred.connect(_effect)

## TODO 死亡掉落的逻辑没有写完
func _effect(..._args):
	if _args[0] == SoraConstant.StatusEnum.Health:
		var item = drop_item.instantiate() as Entity
		SMapData.factor_added.emit(item, c_action.component_owner.main_control.global_position)
