## @editing: Sora [br]
## @describe: 导航组件, 基于此实现针对敌人与友方单位的寻路
@tool
class_name C_Navigation
extends IComponent

enum NavType { stop, pause, track, located }

var current_nav = NavType.stop

@export_subgroup("依赖")
@export var nav_agent: NavigationAgent2D
@export var nav_agent_resource: Array[NavigationAgent2D]

func _enter_tree() -> void:
	component_name = ComponentName.c_navigation

func _initialize(_owner: IEntity):
	super(_owner)
	
