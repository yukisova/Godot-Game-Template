## 实体基类 - ECS架构中的核心载体
## 该抽象类是ECS系统中所有实体的基础类，负责管理组件的生命周期、数据共享和系统交互
## 实体本身不包含具体的游戏逻辑，而是通过组合不同的组件来实现各种功能
## 主要特性：组件生命周期管理、基于黑板的数据共享、异步初始化机制、存档系统支持
## 架构设计：实体作为组件的容器和协调者，通过ContainerBlackboard实现组件间通信
@tool
@abstract class_name IEntity
extends Node2D

## 实体初始化完成信号
## 当所有基础组件初始化完毕后触发，标志着实体已准备好接受游戏逻辑处理
signal initialize_complete

@export_subgroup("核心依赖")

## 主控制节点
## 实体的核心控制对象，通常是CollisionObject2D或其子类，负责处理物理交互、碰撞检测等基础功能
@export var main_control: Node2D

## 组件容器黑板
## 用于组件间数据共享和通信的黑板系统，实现松耦合的组件协作
@export var component_container: ContainerBlackboard

## 基础组件字典
## 存储实体的核心功能组件，在编辑时固定配置，键为IComponent.ComponentName枚举，值为IComponent实例
var list_base_components: Dictionary[int, IComponent] = {}

## 所在的房间索引，默认为-1，表示不在任何房间内
var room_index: int = -1

@abstract func _setup()
@abstract func _update(_delta: float)
@abstract func _fixed_update(_delta: float)
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
	_setup()
	
## 初始化数据绑定—处理动态创建实体时的初始化数据配置，确保数据正确传递给组件系统
## [param context_data]: 统一的初始化数据字典
func _init_data_binding(context_data: Dictionary):
	# 修正数据中的节点路径引用，确保路径指向正确的节点
	var fixed_data = SoraEvent.fixed_dictionary(self, context_data)
	
	# 将修正后的数据传递给组件容器进行解析和分发
	component_container.initilize_data_parse(fixed_data)

func get_other_component(target_component_name: IComponent.ComponentName) -> IComponent:
	var result: IComponent = list_base_components.get(target_component_name)
	if result == null and self is FixedEntity:
		result = self.list_interface_components.get(target_component_name)
	return result
