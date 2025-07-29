##@editing:	Sora
##@describe:	交互逻辑的基类
@abstract class_name Interaction
extends Node

@abstract func _on_interact_activated(_component: IComponent)
@abstract func _on_interact_deactivated(_component: IComponent)
