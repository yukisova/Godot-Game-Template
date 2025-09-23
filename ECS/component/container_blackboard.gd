class_name ContainerBlackboard
extends Node2D

var binding_entity: IEntity
## 已注册的数据
var registered_data: Dictionary = {}

func set_value(target_component_name: IComponent.ComponentName, data_name: StringName, data_value: Variant):
	if not registered_data.has(target_component_name):
		registered_data[target_component_name] = {}
	registered_data[target_component_name][data_name] = data_value
	
func get_value(target_component_name: IComponent.ComponentName, data_name: StringName, default = null) -> Variant:
	return registered_data.get(target_component_name, {}).get(data_name, default)

func has_value(target_component_name: IComponent.ComponentName, data_name: StringName) -> bool:
	return registered_data.get(target_component_name, {}).has(data_name)

## TODO
func _data_parse(context: Dictionary):
	for key in context.keys():
		var data_name = context[key].get("name")
		var data_value = context[key].get("value")
		var data_parser: CBDataParser
		match key:
			IComponent.ComponentName.NONE:
				data_parser = CBD_None.new(self)
			IComponent.ComponentName.C_ACTION_TRIGGER:
				data_parser = CBD_ActionTrigger.new(self)
			IComponent.ComponentName.C_TEXTURE_CONTROLLER:
				data_parser = CBD_TextureController.new(self)
			IComponent.ComponentName.C_COLLISION_BOX:
				data_parser = CBD_CollisionBox.new(self)
			IComponent.ComponentName.C_INPUT_REACTOR:
				data_parser = CBD_InputReactor.new(self)
			IComponent.ComponentName.C_INTERACTABLE:
				data_parser = CBD_Interactable.new(self)
			IComponent.ComponentName.C_STATE_MACHINE:
				data_parser = CBD_StateMachine.new(self)
			IComponent.ComponentName.C_STATUS_LIST:
				data_parser = CBD_StatusList.new(self)
			IComponent.ComponentName.C_NAVIGATION_AGENT:
				data_parser = CBD_NavigationAgent.new(self)
			IComponent.ComponentName.C_BALLOON:
				data_parser = CBD_Balloon.new(self)
			IComponent.ComponentName.C_BEHAVIOUR_TREE:
				data_parser = CBD_BehaviourTree.new(self)
			IComponent.ComponentName.C_ENVIRONMENT_REACTOR:
				data_parser = CBD_EnvironmentReactor.new(self)
			IComponent.ComponentName.C_SOUND_EMITTER:
				data_parser = CBD_SoundEmitter.new(self)
			_:
				data_parser = CBD_None.new(self)
		data_parser.parse(data_name, data_value)

class CBDataParser:
	var container_blackboard: ContainerBlackboard
	func _init(_container_blackboard: ContainerBlackboard) -> void:
		container_blackboard = _container_blackboard

	func parse(data_name: StringName, data_value: Variant):
		if data_value == null or data_name == &"":
			return
	func _default_parse(data_name: StringName, data_value: Variant):
		container_blackboard.set_value(IComponent.ComponentName.NONE, data_name, data_value)

class CBD_None extends CBDataParser:
	func parse(data_name: StringName, data_value: Variant):
		super(data_name, data_value)
		match data_name:
			&"global_position":
				container_blackboard.binding_entity.main_control.global_position = data_value
			_:
				_default_parse(data_name, data_value)

class CBD_ActionTrigger extends CBDataParser:
	func parse(data_name: StringName, data_value: Variant):
		super(data_name, data_value)
		match data_name:
			## TODO 待实现
			_:
				_default_parse(data_name, data_value)

class CBD_TextureController extends CBDataParser:
	func parse(data_name: StringName, data_value: Variant):
		super(data_name, data_value)
		match data_name:
			## TODO 待实现
			_:
				_default_parse(data_name, data_value)

class CBD_CollisionBox extends CBDataParser:
	func parse(data_name: StringName, data_value: Variant):
		super(data_name, data_value)
		match data_name:
			## TODO 待实现
			_:
				_default_parse(data_name, data_value)
		
class CBD_InputReactor extends CBDataParser:
	func parse(data_name: StringName, data_value: Variant):
		super(data_name, data_value)
		match data_name:
			## TODO 待实现
			_:
				_default_parse(data_name, data_value)

class CBD_Interactable extends CBDataParser:
	func parse(data_name: StringName, data_value: Variant):
		super(data_name, data_value)
		match data_name:
			## TODO 待实现
			_:
				_default_parse(data_name, data_value)

class CBD_StateMachine extends CBDataParser:
	func parse(data_name: StringName, data_value: Variant):
		super(data_name, data_value)
		match data_name:
			## TODO 待实现
			_:
				_default_parse(data_name, data_value)

class CBD_StatusList extends CBDataParser:
	func parse(data_name: StringName, data_value: Variant):
		super(data_name, data_value)
		match data_name:
			## TODO 待实现
			_:
				_default_parse(data_name, data_value)

class CBD_NavigationAgent extends CBDataParser:
	func parse(data_name: StringName, data_value: Variant):
		super(data_name, data_value)
		match data_name:
			## TODO 待实现
			_:
				_default_parse(data_name, data_value)

class CBD_Balloon extends CBDataParser:
	func parse(data_name: StringName, data_value: Variant):
		super(data_name, data_value)
		match data_name:
			## TODO 待实现
			_:
				_default_parse(data_name, data_value)

class CBD_BehaviourTree extends CBDataParser:
	func parse(data_name: StringName, data_value: Variant):
		super(data_name, data_value)
		match data_name:
			## TODO 待实现
			_:
				_default_parse(data_name, data_value)

class CBD_EnvironmentReactor extends CBDataParser:
	func parse(data_name: StringName, data_value: Variant):
		super(data_name, data_value)
		match data_name:
			## TODO 待实现
			_:
				_default_parse(data_name, data_value)

class CBD_SoundEmitter extends CBDataParser:
	func parse(data_name: StringName, data_value: Variant):
		super(data_name, data_value)
		match data_name:
			## TODO 待实现
			_:
				_default_parse(data_name, data_value)

## 黑板内的数据类型
## key: IComponent.ComponentName
## value: StringName: Variant
