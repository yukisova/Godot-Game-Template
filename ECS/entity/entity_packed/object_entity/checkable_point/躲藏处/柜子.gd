@tool
extends ObjectEntity


@export_group("依赖")
@export var c_interactable: CInteractable
@export var open_action: ITriggerAction

var interaction: IInteraction

func _setup() -> void:
	
	main_control = StaticBody2D.new()
	add_child(main_control)

	_init_collision()

	for i in get_children():
		if i is CollisionShape2D or i is CollisionPolygon2D:
			i.reparent(main_control)
		if i is IInteraction:
			interaction = i

	interaction.binding_entity = self
	_initialize()

## 传送点初始化—配置传送交互和相关组件的设置
func _initialize() -> void:
	c_interactable.interactions_resources.append(InteractionRecord.new(InteractionRecord.InteractType.RayCasted, false, main_control.get_path(), interaction.get_path()))

	await c_interactable._initialize(self)

	initialize_complete.emit()

## 属性验证—根据传送点类型动态控制编辑器中显示的属性
## [param property]: 属性信息字典
func _validate_property(property: Dictionary) -> void:
	if property.name == "component_container" or property.name == "main_control":
		property.usage = PROPERTY_USAGE_NO_EDITOR
