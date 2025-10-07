@tool
class_name CheckablePoint
extends ObjectEntity

## 在完成交互之后，用于与interact_return内的信息进行对比，从而判断当前的目标是否可以被销毁，如果设置为空，则当前的检查点为一次性，交互完成之后便会直接销毁
@export var check_target: Dictionary

@export var interact_type: InteractionRecord.InteractType
@export var is_passive: bool = false
@export var c_interactable: CInteractable

## 检查用的字典，用于在完成交互之后检查完成的情况，代替InteractCountType，更加自由的判断当前的目标是否可以被销毁
var interact_return: Dictionary = {}

var interaction: IInteraction

func _setup() -> void:
	match interact_type:
		InteractionRecord.InteractType.BodyEntered:
			main_control = InteractBox.new()
			add_child(main_control)
		InteractionRecord.InteractType.AreaEntered:
			main_control = InteractBox.new()
			add_child(main_control)
		InteractionRecord.InteractType.RayCasted:
			main_control = StaticBody2D.new()
			main_control.collision_layer = Main.PhysicsLayer.Wall | Main.PhysicsLayer.Interactable
			add_child(main_control)
		InteractionRecord.InteractType.Null:
			pass

	for i in get_children():
		if i is CollisionShape2D or i is CollisionPolygon2D:
			i.reparent(main_control)
		if i is IInteraction:
			interaction = i

	interaction.binding_entity = self
	interaction.interact_finished.connect(_despawn)
	_initialize()

## 传送点初始化—配置传送交互和相关组件的设置
func _initialize() -> void:
	c_interactable.interactions_resources.append(InteractionRecord.new(interact_type, is_passive, main_control.get_path(), interaction.get_path()))

	await c_interactable._initialize(self)

	initialize_complete.emit()

## 属性验证—根据传送点类型动态控制编辑器中显示的属性
## [param property]: 属性信息字典
func _validate_property(property: Dictionary) -> void:
	if property.name == "component_container" or property.name == "main_control":
		property.usage = PROPERTY_USAGE_NO_EDITOR

func _despawn():
	if check_target.is_empty():
		queue_free()
	else:
		pass
