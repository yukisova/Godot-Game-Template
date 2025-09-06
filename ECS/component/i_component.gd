## 组件基类 - ECS架构中的功能模块基础类
## 定义ECS系统中所有组件的基本接口和功能，分为插件组件和固定组件两种类型
## 主要特性：统一初始化生命周期管理、基于信号的初始化完成通知、存档系统支持、黑板数据共享机制
## [br][b]编辑者:[/b] Sora
@tool
@abstract class_name IComponent
extends Node

signal initialize_complete

## 组件名称枚举，定义ECS系统中所有可用组件的标识符，用于组件的注册和管理
enum ComponentName {
	C_ACTION_TRIGGER = 0, ## 见 [CActionTrigger] 行为触发组件
	C_TEXTURE_CONTROLLER, ## 见 [CTextureController] 纹理渲染组件
	C_COLLISION_BOX, ## 见 [CCollisionBox] 碰撞检测组件
	C_INPUT_REACTOR, ## 见 [CInputReactor] 输入响应组件
	C_INTERACTABLE, ## 见 [CInteractable] 交互处理组件
	C_STATE_MACHINE, ## 见 [CStateMachine] 状态机组件
	C_STATUS_LIST, ## 见 [CStatusList] 状态管理组件
	C_NAVIGATION_AGENT, ## 见 [CNavigationAgent] 导航寻路组件
	C_BALLOON, ## 见 [CBalloon] 气泡显示组件
	C_BEHAVIOUR_TREE, ## 见 [CBehaviourTree] 行为树组件
	C_ENVIRONMENT_REACTOR, ## 见 [CEnvironmentReactor] 环境反应组件
	C_SOUND_EMITTER, ## 见 [CSoundEmitter] 声音发射组件
}

## 外部初始化数据来源，指定在初始化时从 ContainerBlackboard 中获取的自定义初始化值的键名
## TODO: 完善初始化数据处理机制
@export var initialize_from: String

## 组件拥有者，指向拥有此组件的实体对象，支持所有 IEntity 的子类
var component_owner: IEntity

## 实体主碰撞体，指向实体的主要碰撞检测对象，通常是 CollisionObject2D 类型
var component_body: CollisionObject2D

## 组件类型标识，用于在实体的组件字典中进行识别的类型枚举值
var component_name: ComponentName

func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	if Engine.is_editor_hint():
		return
	if _load_data.size() > 0:
		initialize_complete.connect(_load.bind(_load_data))

	component_owner = _owner
	component_body = component_owner.main_control

#region :重置系统: 由实现类进行重写
func _reset():
	pass
#endregion

func _update(_delta: float):
	if Engine.is_editor_hint():
		return

func _fixed_update(_delta: float):
	if Engine.is_editor_hint():
		return

#region :存档系统:
func _save() -> Dictionary:
	return {}

## 加载组件数据，在_initialize初始化时调用，但需要等待initialize_complete信号触发后才能进行加载
## [param _dict]: 包含组件数据的字典
func _load(_dict: Dictionary):
	pass
#endregion

## 获取黑板容器，返回组件拥有者的黑板容器，用于组件间数据共享和通信
## [br][br][b]返回:[/b] 黑板容器实例
func get_blackboard() -> ContainerBlackboard:
	return component_owner.component_container

func get_other_component(target_component_name: ComponentName) -> IComponent:
	var result: IComponent = component_owner.list_base_components.get(target_component_name)
	if result == null and component_owner is FixedEntity:
		result = component_owner.list_interface_components.get(target_component_name)
	return result
