class_name EntityDataTemplate
extends Resource

@export var template_name: String
@export var template_data: Dictionary[IComponent.ComponentName, ContainerBlackboardData]
@export var description: String = ""

func get_template_data() -> Dictionary:
    var result = {}
    for component_name in template_data.keys():
        var blackboard_data = template_data[component_name]
        if blackboard_data:
            result[component_name] = blackboard_data._data
    return result