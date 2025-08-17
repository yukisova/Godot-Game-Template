## 临时实体类 - 专为对象池系统设计的轻量级实体实现
##
## 临时实体是ECS架构中专门用于频繁创建和销毁场景的优化实体。
## 与 [FixedEntity] 不同，临时实体只支持基础组件，不支持接口组件，
## 且针对对象池的生命周期进行了特殊优化。
##
## 设计特点：
## - 轻量级设计，无接口组件支持
## - 集成对象池生命周期管理
## - 支持快速重置和状态恢复
## - 优化的内存使用和性能
##
## 适用场景：
## - 子弹、特效等短生命周期对象
## - 敌人、道具等需要频繁创建的对象
## - 任何需要对象池管理的动态实体
##
## 架构设计：
## - 继承自 [IEntity] 基类
## - 与 [LevelObjectPool] 系统集成
## - 支持 [signal despawned] 回收信号
## - 基于 [StringName] 的对象池标识
##
## [br][b]注意事项:[/b]
## - 不支持存档功能（临时对象不需要持久化）
## - 不支持接口组件动态挂载
## - 生命周期完全由对象池系统管理
##
## [br][b]编辑者:[/b] Sora
@tool
class_name TempEntity
extends IEntity

## 对象池标识符
## 
## 标识该实体所属的对象池，用于对象池管理。类型为 [StringName]。
@export var pool_key: StringName = ""

## 所属对象池引用
## 
## 指向管理该实体的对象池实例，类型为 [LevelObjectPool]。
var level_object_pool: LevelObjectPool

## 实体销毁信号
## 
## 当实体需要回收到对象池时发出的信号。
## [param self]: 要回收的实体实例
signal despawned

## 初始化状态标志
## 
## 标记实体是否已经完成初始化，用于防止重复初始化。
var is_initialized: bool = false

func _setup():
	# 根据实体初始化时机决定立即初始化还是等待信号
	if Main.entity_initialzable:
		_initialize()
	else:
		## 在等待状态下，不可以加入场景树，干脆删掉
		print("临时实体在地图加载前进入场景，只能销毁")
		queue_free()

func _initialize():
	if is_initialized:
		print("已经初始化过了，不需再次初始化")
		return
	# 初始化基础组件（挂载在组件容器下的组件）
	for component in component_container.get_children():
		if (component is IComponent):
			component._initialize(self)
			list_base_components[component.component_name] = component
	
	is_initialized = true
	initialize_complete.emit()

func _update(_delta: float):
	# 只在正常游戏状态下更新组件
	if SGameState.state_machine._get_leaf_state() is GamingStateNormal:
		for base_component in list_base_components.values():
			base_component._update(_delta)
	pass

func _fixed_update(_delta: float):
	# 只在正常游戏状态下更新组件
	if SGameState.state_machine._get_leaf_state() is GamingStateNormal:
		for base_component in list_base_components.values():
			base_component._fixed_update(_delta)

## 回收实体
## 
## 发出销毁信号，对象池接收信号后将实体回收至可用池中等待下一次使用。
func despawn():
	despawned.emit(self)

## 重置实体
## 
## 重置实体的初始化数据和组件状态，为下次使用做准备。
## [param _new_context]: 新的上下文数据，用于重新初始化实体
func reset(_new_context: Dictionary):
	await _init_data_binding(SoraEvent.fixed_dictionary(self, _new_context))
	for component in list_base_components.values():
		component._reset()
