## 对象池
extends ISystem

func _enter_tree() -> void:
	Main.s_object_pool = self
