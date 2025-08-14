## @editing: Sora [br]
## @describe: 组件基类, 分为插件组件和固定组件
@tool
@abstract class_name IComponent
extends Node

signal initialize_complete

enum ComponentType { ## 组件的状态
	BASE = 0, ## 基础组件，在实体编辑时固定的基础性组件
	INTERFACE ## 接口组件, 直接挂载在诸如地图一类的实体子场景下，或通过代码动态挂载在目标实体下。主要面向可能会根据地图信息, 角色行为而需要灵活设置信息的场景
}

enum ComponentName {
	C_ACTION_TRIGGER = 0, ## 见[CActionTrigger]
	C_TEXTURE, ## 见[C_Texture]
	C_CAMERA, ## 见[CCamera]
	C_COLLISION, ## 见[CCollision]
	C_INPUT_REACTOR, ## 见[CInputReactor]
	C_INTERACTABLE, ## 见[CInteractable]
	C_MOVEMENT, ## 见[CMovement]
	C_STATE, ## 见[CState]
	C_STATUS, ## 见[CStatus]
	C_NAVIGATION, ## 见[CNavigation]
	C_BALLOON, ## 见[CBalloon]
	C_MARKER ## 见[CMarker]
}

## TODO 
@export var initialize_from: String ## 在初始化的时候如果需要在外部自定义初始化的值，所在ContainerBlackboard中获取的

var component_owner: IEntity ## 组件的拥有者, 即实体（支持FixedEntity和TempEntity）
var component_body: CollisionObject2D ## 实体的主碰撞体
var component_name: ComponentName ## 用于实体内组件字典进行识别的类型枚举
var component_type: ComponentType: ## 实体的类型
	set(value):
		if (Engine.is_editor_hint()):
			component_type = value
		else:
			printerr(
				"该量运行时不可修改。"
			)
	get:
		return component_type

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

## 加载_initialiaze初始化的时候进行调用，但需要等待initialize_complete信号触发后才能进行加载
func _load(_dict: Dictionary):
	pass
#endregion
