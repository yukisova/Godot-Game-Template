## @editing: Sora [br]
## @describe: 实体类，以组合形式，实现一组逻辑，可以当作是一个平台
@tool
class_name Entity
extends Node2D

signal initialize_complete

@export_group("初始化的黑板信息")
@export var init_data_variant: Dictionary[String, Variant]
@export var init_data_node: Dictionary[String, Node]

@export_subgroup("依赖")
@export var main_control: Node2D  ## 主要控制对象
@export var component_container: ContainerBlackboard

var body: CollisionObject2D:
	get:
		for i in get_children():
			if i is CollisionObject2D:
				return i
		push_error("实体没有发现碰撞体？？？")
		return null

var list_base_components: Dictionary[int, IComponent] = {} ## 基础组件组
var list_interface_components: Dictionary[int, IComponent] = {} ## 插件组件组

## 代码内创建的实体，设定初始信息
func _init_data_binding(context_variant: Dictionary, context_node: Dictionary):
	component_container.initilize_data_parse(context_variant)
	component_container.initilize_data_parse(context_node)

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	await _init_data_binding(init_data_variant, init_data_node)
	
	## 确认是地图加载前ready， 还是地图加载后ready
	if Main.entity_initialzable:
		_initialize()
	else:
		SSignalBus.entity_initialize_started.connect(_initialize.bind(true))

func _initialize(need_disconnect: bool = false):
	for interface in get_children():
		if (interface is IComponent):
			interface._initialize(self)
			list_interface_components[interface.component_name] = interface
	for component in component_container.get_children():
		if (component is IComponent):
			component._initialize(self)
			list_base_components[component.component_name] = component
	if need_disconnect:
		SSignalBus.entity_initialize_started.disconnect(_initialize)
	
	initialize_complete.emit()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if SGameState.state_machine._get_leaf_state() is GamingStateNormal:
		for base in list_base_components.values():
			base._update(delta)
		for base in list_interface_components.values():
			base._update(delta)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if SGameState.state_machine._get_leaf_state() is GamingStateNormal:
		for base in list_base_components.values():
			base._fixed_update(delta)
		for base in list_interface_components.values():
			base._fixed_update(delta)

## TODO 存档文件
func _info_to_dict() -> Dictionary:
	var data := {}
	return data
