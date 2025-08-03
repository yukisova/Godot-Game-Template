## @editing: Sora [br]
## @describe: 移动策略的基类, 包含绑定的实体(通过组件传入)，与黑板节点(用于指定移动方向等信息，子弹实体用的上)
@abstract class_name MoveStrategy
extends Node

var binding_entity: Entity

@export var blackboard: ContainerBlackboard
@abstract func _check_and_init()
@abstract func _update(_delta: float)
