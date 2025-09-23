## [br][b]编辑者:[/b] Sora
@tool
@abstract class_name IEntity
extends Node2D

## 射线交互的信号，用于射线交互组件的交互
## TODO 可以考虑使用PhysicsRayQueryParameters2D进行优化
@warning_ignore("unused_signal")
signal entity_ray_interact(interact_source: IEntity)

## 实体初始化完成信号
## 当所有基础组件初始化完毕后触发，标志着实体已准备好接受游戏逻辑处理
## 当游戏地图加载的时候，只有所有的实体initialize_complete信号都触发后，才能开始进行地图的加载
@warning_ignore("unused_signal")
signal initialize_complete

@export_subgroup("核心依赖")

## 主控制节点
@export var main_control: Node2D

@export var component_container: ContainerBlackboard

var list_base_components: Dictionary[int, IComponent] = {}

## 所在的房间索引，默认为-1，表示不在任何房间内
## FIXME 在有了RayCast之后，可以不用考虑房间
var room_index: int = -1

## 初始化
@abstract func _setup()
## 更新
@abstract func _update(_delta: float)
## 物理更新
@abstract func _fixed_update(_delta: float)
## 初始化
@abstract func _initialize()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_update(delta)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_fixed_update(delta)

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if component_container:
		component_container.binding_entity = self
	_setup()
	
## 初始化数据绑定—处理动态创建实体时的初始化数据配置，确保数据正确传递给组件系统
## [param context_data]: 统一的初始化数据字典
func _init_data_binding(context_data: Dictionary):
	# 修正数据中的节点路径引用，确保路径指向正确的节点
	var fixed_data = SoraEvent.fixed_dictionary(self, context_data)

	# 将修正后的数据传递给组件容器进行解析和分发
	component_container._data_parse(fixed_data)

func get_other_component(target_component_name: IComponent.ComponentName) -> IComponent:
	var result: IComponent = list_base_components.get(target_component_name)
	if result == null and self is FixedEntity:
		result = self.list_interface_components.get(target_component_name)
	return result
