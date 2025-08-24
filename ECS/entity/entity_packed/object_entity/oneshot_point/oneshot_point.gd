## 一次性触发点
## 用于触发一次性的交互，在触发之后会自动销毁，并在存档中记录
## 触发后会自动销毁
@tool
class_name OneshotPoint
extends ObjectEntity

@export var interaction_box: InteractionRecord.InteractType
@export var interaction_disable: bool = false
@export var interact_is_passive: bool = false
@export var c_interactable: CInteractable

## 传送点设置—初始化传送点的碰撞组件和交互系统
func _setup() -> void:
	for i in get_children():
		if i is CollisionShape2D or i is CollisionPolygon2D:
			i.reparent(main_control)
	_initialize()

## 传送点初始化—配置传送交互和相关组件的设置
func _initialize() -> void:
	# 如果传送点被禁用，则不进行传送
	var type: InteractionRecord.InteractType = InteractionRecord.InteractType.BodyEntered
	if interaction_disable:
		type = InteractionRecord.InteractType.Null
	
	var interaction: Interaction
	

	# 动态加入传送交互
	c_interactable.interactions_resources.append(InteractionRecord.new(type, interact_is_passive, main_control.get_path(), interaction.get_path()))

	await c_interactable._initialize(self)

	initialize_complete.emit()

## 属性验证—根据传送点类型动态控制编辑器中显示的属性
## [param property]: 属性信息字典
func _validate_property(property: Dictionary) -> void:
	if property.name == "component_container" or property.name == "main_control":
		property.usage = PROPERTY_USAGE_NO_EDITOR
