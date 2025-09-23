@tool
class_name TempEntity
extends IEntity

## 对象池标识符
## 标识该实体所属的对象池，用于对象池管理
@export var pool_key: StringName = ""

## 所属对象池引用
## 指向管理该实体的对象池实例
var level_object_pool: LevelObjectPool

## 实体销毁信号
## 当实体需要回收到对象池时发出的信号
signal despawned

## 初始化状态标志
## 标记实体是否已经完成初始化，用于防止重复初始化
var has_initialized: bool = false

func _setup():
	## 1. TempEntity只能在地图加载完毕后才能被允许创建，否则为非法创建只能销毁
	if Main.entity_initialzable:
		_initialize()
	else:
		queue_free()

func _initialize():
	if has_initialized:
		return
	# 初始化基础组件（挂载在组件容器下的组件）
	for component in component_container.get_children():
		if (component is IComponent):
			component._initialize(self)
			list_base_components[component.component_name] = component
	
	has_initialized = true
	initialize_complete.emit()

func _update(_delta: float):
	# 只在正常游戏状态下更新组件
	if SGameState.state_machine.get_leaf_state() is GamingStateNormal:
		for base_component in list_base_components.values():
			base_component._update(_delta)

func _fixed_update(_delta: float):
	# 只在正常游戏状态下更新组件
	if SGameState.state_machine.get_leaf_state() is GamingStateNormal:
		for base_component in list_base_components.values():
			base_component._fixed_update(_delta)

## 回收实体—发出销毁信号，对象池接收信号后将实体回收至可用池中等待下一次使用
func despawn():
	despawned.emit(self)

## 重置实体—重置实体的初始化数据和组件状态，为下次使用做准备
## [param _new_context]: 新的上下文数据
func reset(_new_context: Dictionary):
	await _init_data_binding(SoraEvent.fixed_dictionary(self, _new_context))
	for component in list_base_components.values():
		component._reset()

## 第一次加载->initialize()->使用完毕->despawn()->在对象池中被选中->reset()->使用完毕->despawn()