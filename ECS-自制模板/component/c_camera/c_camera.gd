## 镜头
@tool
class_name C_Camera
extends IComponent

@export_subgroup("依赖")
@export var camera: Camera2D

func _enter_tree() -> void:
	component_name = ComponentName.c_camera

func _initialize(_owner: Entity):
	super(_owner)
