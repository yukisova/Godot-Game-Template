@tool
@abstract class_name IEntity
extends Node2D

## 实体初始化完成信号
## 当所有基础组件初始化完毕后触发
signal initialize_complete

@export_subgroup("核心依赖")
## 主控制节点
## 实体的核心控制对象，通常是碰撞体或运动体
@export var main_control: Node2D

## 组件容器黑板
## 用于组件间数据共享和通信的黑板系统
@export var component_container: ContainerBlackboard

## 基础组件字典
## 存储实体的核心功能组件，在编辑时固定配置
var list_base_components: Dictionary[int, IComponent] = {}


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
	
## 初始化数据绑定
## 处理动态创建实体时的初始化数据配置
## @param context_data: 统一的初始化数据字典
func _init_data_binding(context_data: Dictionary):
	# 修正数据中的节点路径引用
	var fixed_data = SoraEvent.fixed_dictionary(self, context_data)
	
	# 将修正后的数据传递给组件容器
	component_container.initilize_data_parse(fixed_data)