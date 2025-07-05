@tool
class_name C_Navigation
extends IComponent

enum NavType { stop, pause, track, located}

var current_nav = NavType.stop

@export_subgroup("依赖")
@export var nav_agent: NavigationAgent2D



func _enter_tree() -> void:
	component_name = ComponentName.c_navigation
