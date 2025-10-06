## 门的实体，会在地图tile中使用，类似dr2c
@tool
extends ObjectEntity

@export var has_lock: bool = false:
	set(v):
		has_lock = v
		notify_property_list_changed()

@export var is_passive: bool = false

@export var room_trigger_u_l_room: Room
@export var room_trigger_d_r_room: Room

@export_group("门在有锁的情况下的设置")
## 锁对应的钥匙的item_nick_name
@export var lock_key_nick_name: String = ""

@export_group("依赖")
@export var room_trigger_1: Area2D
@export var room_trigger_2: Area2D
@export var c_interactable: CInteractable
@export var open_action: ITriggerAction


var interaction: IInteraction

func _setup() -> void:
	open_action.has_lock = has_lock
	open_action.lock_key_nick_name = lock_key_nick_name
	
	room_trigger_1.body_entered.connect(_on_area_1_entered)
	room_trigger_1.body_exited.connect(_on_area_1_exited)

	room_trigger_2.body_entered.connect(_on_area_2_entered)
	room_trigger_2.body_exited.connect(_on_area_2_exited)
	
	main_control = InteractBox.new()
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
	c_interactable.interactions_resources.append(InteractionRecord.new(InteractionRecord.InteractType.BodyEntered, is_passive, main_control.get_path(), interaction.get_path()))

	await c_interactable._initialize(self)

	initialize_complete.emit()

## 属性验证—根据传送点类型动态控制编辑器中显示的属性
## [param property]: 属性信息字典
func _validate_property(property: Dictionary) -> void:
	if property.name == "component_container" or property.name == "main_control":
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if !has_lock:
		if property.name == "lock_key_nick_name":
			property.usage = PROPERTY_USAGE_NO_EDITOR


var current_enter: Array[int] = []
func _on_area_1_entered(body: Node2D):
	if body.is_in_group("player"):
		current_enter.push_front(0)
		try_update_room()

func _on_area_1_exited(body: Node2D):
	if body.is_in_group("player"):
		current_enter.erase(0)
		try_update_room()
		
func _on_area_2_entered(body: Node2D):
	if body.is_in_group("player"):
		current_enter.push_front(1)
		try_update_room()

func _on_area_2_exited(body: Node2D):
	if body.is_in_group("player"):
		current_enter.erase(1)
		try_update_room()

func try_update_room():
	print(current_enter)
	if current_enter.is_empty():
		return
	match current_enter[0]:
		0:
			SMapData.current_level.rooms.room_changed.emit(room_trigger_u_l_room)
		1:
			SMapData.current_level.rooms.room_changed.emit(room_trigger_d_r_room)
