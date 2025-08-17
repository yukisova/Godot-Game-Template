@tool
class_name TransportPoint
extends ObjectEntity

enum TransportPointType {
	ROOM, ## 基于房间的传送
	LEVEL, ## 基于层级的传送
	MAP, ## 基于地图的传送
}

## 懒得指定目标的节点引用了，直接指定目标的key
@export var transport_point_type: TransportPointType = TransportPointType.LEVEL:
	set(value):
		transport_point_type = value
		notify_property_list_changed()

@export var transport_map: PackedScene:
	set(value):
		transport_map = value
		notify_property_list_changed()

@export var target_map_path: String = "": ## 目标地图路径（避免循环引用）
	set(value):
		target_map_path = value
		notify_property_list_changed()

@export_range(-1, 10, 1, "or_greater") var target_level_index: int = -1: ## 目标传送层级索引
	set(value):
		target_level_index = value
		notify_property_list_changed()

@export var target_level_name: StringName = &"": ## 目标传送层级
	set(value):
		target_level_name = value
		notify_property_list_changed()

@export var transport_point_key: String ## 当前传送点的key
@export var target_transport_point_key: String ## 目标传送点的key
@export var tranported_offset: Vector2 = Vector2.ZERO ## 传送点的偏移量，在其他传送点传送实体至本传送点时，会加上这个偏移量，以便于实体正常传送
@export var interact_is_passive: bool = false ## 到达本传送点时，是否被动传送，如果为false，则需要玩家主动触发传送
@export var transport_disable: bool = false ## 是否禁用传送，如果为true，则无法被其他传送点传送
@export var enable_export_to_map: bool = false ## 是否将当前传送点导出到地图中, 如果为true, 则可以直接被其他的地图传送引用


@export_group("传送点的依赖")
@export var c_interactable: CInteractable
@export var interaction_transport: InteractionTransport

func _setup() -> void:
	for i in get_children():
		if i is CollisionShape2D or i is CollisionPolygon2D:
			i.reparent(main_control)
	_initialize()

func _initialize() -> void:
	## 如果传送点被禁用，则不进行传送
	var type: InteractionRecord.InteractType = InteractionRecord.InteractType.BodyEntered
	if transport_disable:
		type = InteractionRecord.InteractType.Null
	## 动态加入传送交互的
	c_interactable.interactions_resources.append(InteractionRecord.new(type, interact_is_passive, main_control.get_path(), interaction_transport.get_path()))

	await c_interactable._initialize(self)
	# interaction_transport的数据信息设置

	interaction_transport.target_map = transport_map if transport_point_type == TransportPointType.MAP else null
	interaction_transport.target_map_path = target_map_path if transport_point_type == TransportPointType.MAP else ""
	if transport_point_type == TransportPointType.LEVEL:
		interaction_transport.target_level_index = target_level_index
		interaction_transport.target_level_name = target_level_name
	else:
		interaction_transport.target_level_index = -1
		interaction_transport.target_level_name = &""
	interaction_transport.target_key = target_transport_point_key

	initialize_complete.emit()

func _update(_delta: float) -> void:
	pass

func _fixed_update(_delta: float) -> void:
	pass

func _validate_property(property: Dictionary) -> void:
	if property.name == "component_container":
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if transport_point_type == TransportPointType.LEVEL:
		if property.name == "transport_map" or property.name == "target_map_path":
			property.usage = PROPERTY_USAGE_NO_EDITOR
		if target_level_index != -1 and property.name == "target_level_name":
			property.usage = PROPERTY_USAGE_NO_EDITOR
		if target_level_name != &"" and property.name == "target_level_index":
			property.usage = PROPERTY_USAGE_NO_EDITOR
	if transport_point_type == TransportPointType.ROOM:
		if property.name == "transport_map" or property.name == "target_map_path" or property.name == "target_level_name" or property.name == "target_level_index" or property.name == "target_level_enum":
			property.usage = PROPERTY_USAGE_NO_EDITOR
