## 灯的脚本，可以被开关点亮，但更加重要的是它本身可以发生闪烁，黯淡的效果 
@tool
extends ObjectEntity

@export var default_lights: Texture2D
var point_lights: Array[Light2D] = []

@export var c_interactable: CInteractable
@export var is_passive: bool
@export var interaction: InteractionSwitch

func _setup() -> void:
	main_control = InteractBox.new()
	add_child(main_control)

	for i in get_children():
		if i is CollisionShape2D or i is CollisionPolygon2D:
			i.reparent(main_control)
		if i is PointLight2D:
			point_lights.append(i)
	
	if point_lights.is_empty():
		var point_light = PointLight2D.new()
		add_child(point_light)
		point_light.texture = default_lights
		point_lights.append(point_light)
	
	interaction.binding_entity = self
	
	_init_collision()
	_initialize()

func _initialize() -> void:
	c_interactable.interactions_resources.append(InteractionRecord.new(InteractionRecord.InteractType.BodyEntered, is_passive, main_control.get_path(), interaction.get_path()))
	
	for i in point_lights:
		interaction.switch_target[i] = "enabled"
	
	await c_interactable._initialize(self)

	initialize_complete.emit()

## 灯光的闪烁效果
func blink(duration: float = 0.4, count: int = 3):
	pass

## 控制灯光的明暗
func frightness(value: float = 1):
	pass
