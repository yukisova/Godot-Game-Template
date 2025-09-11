@tool
class_name CBehaviourTree
extends IComponent

## 行为树Resource
@export var behaviour_tree: BehaviorTree
## 行为树初始化数据
@export var blackboard_data: Dictionary[String, Variant]

@export_group("依赖")
@export var behaviour_tree_player: BTPlayer

func _enter_tree() -> void:
	component_name = ComponentName.C_BEHAVIOUR_TREE

func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)

	if behaviour_tree_player:
		behaviour_tree_player.agent_node = get_path()
		behaviour_tree_player.behavior_tree = behaviour_tree.duplicate()
		behaviour_tree_player.process_mode = ProcessMode.PROCESS_MODE_INHERIT
		behaviour_tree_player.active = true

		var fixed_blackboard_data = SoraEvent.fixed_dictionary(self, blackboard_data)
		for key in fixed_blackboard_data.keys():
			behaviour_tree_player.blackboard.set_var(key, fixed_blackboard_data[key])
	initialize_complete.emit()
