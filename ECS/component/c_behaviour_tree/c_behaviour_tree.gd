@tool
class_name CBehaviourTree
extends IComponent

## 行为树Resource
@export var behaviour_tree: BehaviorTree

@export_group("依赖")
@export var behaviour_tree_player: BTPlayer

func _enter_tree() -> void:
	component_name = ComponentName.C_BEHAVIOUR_TREE

func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)

	if behaviour_tree_player:
		behaviour_tree_player.agent_node = get_path()
		behaviour_tree_player.behavior_tree = behaviour_tree.duplicate()

	initialize_completed.emit()

func _late_initialize():
	var blackboard_data = get_blackboard().get_all_values(component_name)
	for key in blackboard_data.keys():
		behaviour_tree_player.blackboard.set_var(key, blackboard_data[key])
		
	behaviour_tree_player.process_mode = ProcessMode.PROCESS_MODE_INHERIT
	behaviour_tree_player.active = true
