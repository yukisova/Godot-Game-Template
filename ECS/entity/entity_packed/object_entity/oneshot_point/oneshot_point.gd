## 一次性触发点
## 用于触发一次性的交互，在触发之后会自动销毁，并在存档中记录
## 触发后会自动销毁
@tool
class_name OneshotPoint
extends ObjectEntity

@export var interact_type: InteractionRecord.InteractType
@export var interact_is_passive: bool = false
@export var c_interactable: CInteractable

var interaction: Interaction

## 传送点设置—初始化传送点的碰撞组件和交互系统
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
			add_child(main_control)
		InteractionRecord.InteractType.Null:
			pass
	
	
	
	for i in get_children():
		if i is CollisionShape2D or i is CollisionPolygon2D:
			i.reparent(main_control)
		if i is Interaction:
			interaction = i
	
	interaction.binding_entity = self
	
	interaction.interact_finished.connect(func():
		print("一次性触发点触发，进行销毁")
		queue_free()
	)
	_initialize()

## 传送点初始化—配置传送交互和相关组件的设置
func _initialize() -> void:
	c_interactable.interactions_resources.append(InteractionRecord.new(interact_type, interact_is_passive, main_control.get_path(), interaction.get_path()))

	await c_interactable._initialize(self)

	initialize_complete.emit()

## 属性验证—根据传送点类型动态控制编辑器中显示的属性
## [param property]: 属性信息字典
func _validate_property(property: Dictionary) -> void:
	if property.name == "component_container" or property.name == "main_control":
		property.usage = PROPERTY_USAGE_NO_EDITOR
