## 固定实体类 - ECS架构中的具体实体实现
## 实体是ECS架构的核心概念之一，它作为组件的载体和逻辑平台，采用组合模式，通过挂载不同的组件来实现各种功能和行为
## 架构特点：基于组件组合的设计模式、支持基础组件和接口组件两种类型、提供统一的生命周期管理、集成存档系统支持
## 功能特性：组件自动发现和管理、数据驱动的初始化、生命周期事件通知、交互系统集成
## 架构设计：继承自IEntity基类、支持entity_ray_interact射线交互、与Main系统的实体初始化集成、基于SavedDataFile的存档系统支持
## [br][b]编辑者:[/b] Sora
@tool
class_name FixedEntity
extends IEntity

## 实体射线交互信号
## 用于处理基于RayCast2D的实体间交互，主要用于玩家与环境对象的交互
@warning_ignore("unused_signal")
signal entity_ray_interact(interact_source: IEntity)

@export_group("初始化数据配置")

## 统一初始化数据
## 用于在运行时动态配置实体的基础属性和节点引用，支持Variant类型数据和NodePath类型引用
@export var init_data: Dictionary

## 实体原生存在标志
## 标识实体是否为静态地图中的原生对象（vs动态创建的对象）
var is_entity_origin_exist: bool

## 接口组件字典
## 存储可动态挂载的功能组件，支持运行时添加/移除，键为组件类型枚举，值为IComponent实例
var list_interface_components: Dictionary[int, IComponent] = {}

## Godot生命周期—节点准备就绪，处理实体的初始化时机判断和数据绑定
func _setup():
	# 根据实体初始化时机决定立即初始化还是等待信号
	if Main.entity_initialzable:
		_initialize()
	else:
		SSignalBus.entity_initialize_started.connect(_initialize.bind(true))

## 实体初始化—初始化所有组件并建立组件字典，处理存档数据恢复
## [param need_disconnect]: 是否需要断开信号连接
func _initialize(need_disconnect: bool = false):
	await _init_data_binding(SoraEvent.fixed_dictionary(self, init_data))

	var load_data_for_components = {}
	# 如果存在存档数据，先加载存档
	if SLoadAndSave.current_saved:
		load_data_for_components = _load_by(SLoadAndSave.current_saved)
	
	# 初始化接口组件（直接挂载在实体下的组件）
	for interface in get_children():
		if (interface is IComponent):
			interface._initialize(self, load_data_for_components.get(interface.component_name, {}))
			list_interface_components[interface.component_name] = interface
	
	# 初始化基础组件（挂载在组件容器下的组件）
	for component in component_container.get_children():
		if (component is IComponent):
			component._initialize(self, load_data_for_components.get(component.component_name, {}))
			list_base_components[component.component_name] = component

	# 如果是延迟初始化，断开信号连接
	if need_disconnect:
		SSignalBus.entity_initialize_started.disconnect(_initialize)
	
	# 发出初始化完成信号
	initialize_complete.emit()

## 主循环更新—在正常游戏状态下更新所有组件
## [param _delta]: 帧时间间隔

func _update(_delta: float):
	# 只在正常游戏状态下更新组件
	if SGameState.state_machine._get_leaf_state() is GamingStateNormal:
		for base_component in list_base_components.values():
			base_component._update(_delta)
		for interface_component in list_interface_components.values():
			interface_component._update(_delta)

## 物理更新—在正常游戏状态下执行组件的物理更新
## [param _delta]: 物理帧时间间隔
func _fixed_update(_delta: float):
	# 只在正常游戏状态下执行物理更新
	if SGameState.state_machine._get_leaf_state() is GamingStateNormal:
		for base_component in list_base_components.values():
			base_component._fixed_update(_delta)
		for interface_component in list_interface_components.values():
			interface_component._fixed_update(_delta)

#region 存档系统
## 保存实体数据—将实体及其所有组件的状态保存到存档数据中
## [param _data]: 存档数据文件对象
func _save_as(_data: SavedDataFile) -> Dictionary:
	return {}
	
## 加载实体数据—从存档数据中恢复实体及其组件的状态
## [param _data]: 存档数据文件对象
func _load_by(_data: SavedDataFile) -> Dictionary:
	return {}
#endregion
