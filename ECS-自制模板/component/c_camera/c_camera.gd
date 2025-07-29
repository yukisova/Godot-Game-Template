## @editing: Sora
## @describe: 聚焦于实体的Camera组件，包含Camera的跟随策略
@tool
class_name C_Camera
extends IComponent

@export_subgroup("镜头控制策略")

@export var strategy: CameraFollowStrategy

@export_subgroup("依赖")
@export var camera: Camera2D


func _enter_tree() -> void:
	component_name = ComponentName.c_camera

func _initialize(_owner: Entity):
	super(_owner)
	
	strategy.c_camera = self
	
func _update(_delta: float):
	strategy._strategy(_delta)
