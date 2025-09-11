@tool
class_name CBehaviourTree
extends IComponent

@export var behaviour_tree: BehaviorTree

@export_group("依赖")
@export var behaviour_tree_player: BTPlayer

func _enter_tree() -> void:
    component_name = ComponentName.C_BEHAVIOUR_TREE

func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
    super._initialize(_owner, _load_data)

    if behaviour_tree_player:
        behaviour_tree_player.agent_node = get_path()
        behaviour_tree_player.behavior_tree = behaviour_tree
        behaviour_tree_player.process_mode = ProcessMode.PROCESS_MODE_INHERIT
        behaviour_tree_player.active = true

    initialize_complete.emit()