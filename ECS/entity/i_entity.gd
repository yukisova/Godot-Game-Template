## [br][b]编辑者:[/b] Sora
@tool
@abstract class_name IEntity
extends Node2D

## 射线交互的信号，用于射线交互组件的交互
signal entity_ray_interact(interact_source: IEntity)
signal entity_ray_interact_lose(interact_source: IEntity)

## 实体初始化完成信号
## 当所有基础组件初始化完毕后触发，标志着实体已准备好接受游戏逻辑处理
## 当游戏地图加载的时候，只有所有的实体initialize_complete信号都触发后，才能开始进行地图的加载
@warning_ignore("unused_signal")
signal initialize_complete

@export_subgroup("核心依赖")

## 主控制节点
@export var main_control: Node2D

@export var component_container: ContainerBlackboard

@export var collision_group_records: Dictionary[int, CollisionGroupRecord]
## 实体主碰撞体对应的碰撞区域列表
var collsion_list: Array[Node2D] = []
var collision_groups: Dictionary[String, CollisionGroup] = {}
var current_collision_group: CollisionGroup:
	set(v):
		if v == null: return
		if current_collision_group:
			current_collision_group.toggle_off()
		current_collision_group = v
		if current_collision_group:
			current_collision_group.toggle_on()

var list_base_components: Dictionary[int, IComponent] = {}

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

	## 获取实体主碰撞体对应的碰撞区域列表
	var check_parent: Node2D = self
	if main_control:
		check_parent = main_control
	for i in check_parent.get_children():
		if i is CollisionShape2D or i is CollisionPolygon2D:
			collsion_list.append(i)

	if component_container:
		component_container.binding_entity = self
	_setup()

func _init_collision(default_collision_layer: int = 1) -> void:
	if collision_group_records.is_empty():
		current_collision_group = CollisionGroup.new(main_control, default_collision_layer, collsion_list)
		return

	var sorted_keys = collision_group_records.keys()
	sorted_keys.sort()
	var start_index = 0
	for end_index in sorted_keys:
		var group_info = collision_group_records[end_index]
		if end_index >= collsion_list.size():
			end_index = collsion_list.size() - 1
		var _collision_list = []
		for i in range(start_index, end_index + 1):
			_collision_list.append(collsion_list[i])
		collision_groups[group_info.group_name] = CollisionGroup.new(main_control, group_info.collision_layer, _collision_list)

		if start_index == 0:
			current_collision_group = collision_groups[group_info.group_name]
		start_index = end_index+1

## 销毁实体的方法，默认为直接释放，但是可以被重写，实现类似玩家一样的不死但是弹出游戏结束
func _despawn():
	queue_free()
	
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

class CollisionGroup:
	var main_control: Node2D
	var collision_list: Array = []
	var physics_layers: int

	func _init(_main_control: Node2D, _physics_layers: int, _collision_list: Array):
		main_control = _main_control
		physics_layers = _physics_layers
		collision_list = _collision_list

	func toggle_on():
		for i in collision_list:
			i.disabled = false
		main_control.collision_layer = physics_layers
	
	func toggle_off():
		for i in collision_list:
			i.disabled = true
