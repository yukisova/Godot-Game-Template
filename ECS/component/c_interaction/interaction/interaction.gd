## @editing: Sora [br]
## @describe: 被动交互逻辑的基类，主要用于触发后立即触发交互的逻辑
@abstract class_name PassiveInteraction
extends Node

var binding_entity

## 允许进行交互(如果是被动交互的话，会直接)
@abstract func _on_interact_activated(target_entity: Entity, _component: IComponent)

## 中止待触发的逻辑
@abstract func _on_interact_deactivated(_component: IComponent)
