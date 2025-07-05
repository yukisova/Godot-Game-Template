## 拾取交互
extends Interaction

func _on_interact_activated(component: IComponent):
	print("被收集了")
	
	component.component_owner.queue_free.call_deferred()
