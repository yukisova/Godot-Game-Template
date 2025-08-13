## @editing: Sora [br]
## @describe: 实体基类 - ECS架构中的实体（Entity）实现
## 
## 实体是ECS架构的核心概念之一，它作为组件的载体和逻辑平台。
## 采用组合模式，通过挂载不同的组件来实现各种功能和行为。
## 
## 架构特点：
## - 基于组件组合的设计模式
## - 支持基础组件和接口组件两种类型
## - 提供统一的生命周期管理
## - 集成存档系统支持
## 
## 功能特性：
## - 组件自动发现和管理
## - 数据驱动的初始化
## - 生命周期事件通知
## - 交互系统集成
@tool
class_name IEntity
extends Node2D

## 实体初始化完成信号
## 当所有组件初始化完毕后触发，表示实体已准备就绪
signal initialize_complete

## 实体射线交互信号
## 用于处理基于RayCast的实体间交互，主要用于玩家与环境对象的交互
@warning_ignore("unused_signal")
signal entity_ray_interact(interact_source: IEntity)

@export_group("初始化数据配置")
## 初始化用的变量数据
## 用于在运行时动态配置实体的基础属性
@export var init_data_variant: Dictionary[String, Variant]

## 初始化用的节点数据  
## 用于在运行时动态配置实体关联的节点引用
@export var init_data_node: Dictionary[String, Node]

@export_subgroup("核心依赖")
## 主控制节点
## 实体的核心控制对象，通常是碰撞体或运动体
@export var main_control: Node2D

## 组件容器黑板
## 用于组件间数据共享和通信的黑板系统
@export var component_container: ContainerBlackboard

## 实体原生存在标志
## 标识实体是否为静态地图中的原生对象（vs 动态创建的对象）
var is_entity_origin_exist: bool

## 基础组件字典
## 存储实体的核心功能组件，在编辑时固定配置
var list_base_components: Dictionary[int, IComponent] = {}

## 接口组件字典  
## 存储可动态挂载的功能组件，支持运行时添加/移除
var list_interface_components: Dictionary[int, IComponent] = {}

## 初始化数据绑定
## 处理动态创建实体时的初始化数据配置
## @param context_variant: 变量类型的初始化数据
## @param context_node: 节点类型的初始化数据
func _init_data_binding(context_variant: Dictionary, context_node: Dictionary):
	component_container.initilize_data_parse(context_variant)
	component_container.initilize_data_parse(context_node)

## Godot生命周期：节点准备就绪
## 处理实体的初始化时机判断和数据绑定
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	# 绑定初始化数据
	await _init_data_binding(init_data_variant, init_data_node)
	
	# 根据实体初始化时机决定立即初始化还是等待信号
	if Main.entity_initialzable:
		_initialize()
	else:
		SSignalBus.entity_initialize_started.connect(_initialize.bind(true))

## 实体初始化
## 初始化所有组件并建立组件字典，处理存档数据恢复
## @param need_disconnect: 是否需要断开信号连接（用于延迟初始化场景）
func _initialize(need_disconnect: bool = false):
	# 如果存在存档数据，先加载存档
	if SLoadAndSave.current_saved:
		_load_by(SLoadAndSave.current_saved)

	# 初始化接口组件（直接挂载在实体下的组件）
	for interface in get_children():
		if (interface is IComponent):
			interface._initialize(self)
			list_interface_components[interface.component_name] = interface
	
	# 初始化基础组件（挂载在组件容器下的组件）
	for component in component_container.get_children():
		if (component is IComponent):
			component._initialize(self)
			list_base_components[component.component_name] = component
	
	# 如果是延迟初始化，断开信号连接
	if need_disconnect:
		SSignalBus.entity_initialize_started.disconnect(_initialize)
	
	# 发出初始化完成信号
	initialize_complete.emit()

## 主循环更新
## 在正常游戏状态下更新所有组件
## @param delta: 帧时间间隔
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	# 只在正常游戏状态下更新组件
	if SGameState.state_machine._get_leaf_state() is GamingStateNormal:
		for base_component in list_base_components.values():
			base_component._update(delta)
		for interface_component in list_interface_components.values():
			interface_component._update(delta)

## 物理更新
## 在正常游戏状态下执行组件的物理更新
## @param delta: 物理帧时间间隔
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	# 只在正常游戏状态下执行物理更新
	if SGameState.state_machine._get_leaf_state() is GamingStateNormal:
		for base_component in list_base_components.values():
			base_component._fixed_update(delta)
		for interface_component in list_interface_components.values():
			interface_component._fixed_update(delta)

#region 存档系统
## 保存实体数据
## 将实体及其所有组件的状态保存到存档数据中
## @param _data: 存档数据文件对象（当前未使用，为将来扩展预留）
## @return: 包含实体完整信息的存档字典
func _save_as(_data: SavedDataFile):
	var result: Dictionary = {}
	result["type"] = "entity"
	
	# 保存实体基础信息
	result[" "] = {
		"start_position": global_position,          # 实体初始位置
		"current_position": main_control.global_position,  # 当前位置
		"scene_file_path": scene_file_path,         # 场景文件路径
		"current_level_index": get_parent().get_index()    # 在关卡中的索引
	}
	
	# 保存所有基础组件的数据
	for component in list_base_components.values():
		result.merge(component._save_as())
	
	# 保存所有接口组件的数据
	for component in list_interface_components.values():
		result.merge(component._save_as())
	
	return {
		name: result
	}
	
## 加载实体数据
## 从存档数据中恢复实体及其组件的状态
## @param _data: 存档数据文件对象（当前未使用，为将来扩展预留）
## @param args: 额外的加载参数
func _load_by(_data: SavedDataFile, ...args):
	# 等待实体初始化完成
	await initialize_complete
	
	if args.size() > 0 and args[0] is Dictionary:
		var dict = args[0]
		
		# 恢复实体位置信息
		global_position = dict[" "]["start_position"]
		main_control.global_position = dict[" "]["current_position"]
		
		# 恢复组件数据
		for key in dict.keys():
			if key in IComponent.ComponentName and key in list_base_components:
				list_base_components[key]._load_by(dict[key])
#endregion
