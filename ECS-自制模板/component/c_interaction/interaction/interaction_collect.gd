##@editing:	Sora
##@describe:	拾取交互，之后会更加生动
extends Interaction

func _on_interact_activated(_component: IComponent):
	print("被收集了")
	
	_component.component_owner.queue_free.call_deferred()

func _on_interact_deactivated(_component: IComponent):
	pass
