##@editing:	Sora
##@describe:	移动组件, 让实体根据指定的移动策略实现向量移动功能，或是沿指定的轨迹进行飞行
@tool
class_name C_Movement
extends IComponent

@export var move_strategy: MoveStrategy

func _enter_tree() -> void:
	component_name = ComponentName.c_movement

func _initialize(_owner: Entity):
	super._initialize(_owner)

	move_strategy.binding_entity = component_owner
	move_strategy._check_and_init()

## 移动逻辑的实现
func _update(_delta: float):
	move_strategy._update(_delta)
