##@editing:	Sora
##@describe:	实体行为的基类, 需要与对应的行为组件进行绑定, 靠实现类实现具体的逻辑
@abstract class_name Action
extends Node2D

var c_action: IComponent

@abstract func _effect(..._args)
