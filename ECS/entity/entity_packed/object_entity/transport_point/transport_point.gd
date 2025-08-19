## 传送点 - 实现场景和地图间的玩家传送功能
## 该实体实现了完整的传送系统，支持房间内、层级间和地图间的多种传送方式，提供灵活的传送配置和自动化的传送逻辑
## 核心功能：多种传送类型支持（房间、层级、地图）、自动和手动传送模式、传送点的偏移量控制、传送状态的启用/禁用、地图导出和引用管理
## 传送类型：ROOM基于房间的传送、LEVEL基于层级的传送、MAP基于地图的传送
## 主要特性：智能的属性显示控制、动态的交互配置、碰撞检测的自动处理、传送交互的集成、完整的传送生命周期管理
## 使用场景：房间和区域的连接、楼层间的移动、大地图间的快速旅行、副本和特殊区域的进入、返回点和存档点
## 架构设计：继承自ObjectEntity基类，使用@tool支持编辑器功能，基于枚举的传送类型管理，集成CInteractable和InteractionTransport
## [br][b]编辑者:[/b] Sora
@tool
class_name TransportPoint
extends ObjectEntity

## 传送点类型枚举
## 定义传送点支持的三种传送方式
enum TransportPointType {
	ROOM,  ## 基于房间的传送
	LEVEL, ## 基于层级的传送
	MAP,   ## 基于地图的传送
}

## 传送点类型
## 传送点的类型，决定了传送的目标和方式
@export var transport_point_type: TransportPointType = TransportPointType.LEVEL:
	set(value):
		transport_point_type = value
		notify_property_list_changed()

## 目标地图路径
## 目标地图的路径字符串（避免循环引用）
@export_file_path("*.tscn") var target_map_path: String = "":
	set(value):
		target_map_path = value
		notify_property_list_changed()

## 目标层级索引
## 目标传送层级的数字索引（-1表示使用名称）
@export_range(-1, 10, 1, "or_greater") var target_level_index: int = -1:
	set(value):
		target_level_index = value
		notify_property_list_changed()

## 目标层级名称
## 目标传送层级的名称标识符
@export var target_level_name: StringName = &"":
	set(value):
		target_level_name = value
		notify_property_list_changed()

## 传送点标识符
## 当前传送点的唯一标识符
@export var transport_point_key: String

## 目标传送点标识符
## 目标传送点的唯一标识符
@export var target_transport_point_key: String

## 传送偏移量
## 传送时的位置偏移量，其他传送点传送实体到此处时会应用此偏移
@export var tranported_offset: Vector2 = Vector2.ZERO

## 被动传送模式
## 是否在到达传送点时自动传送，false则需要玩家主动触发
@export var interact_is_passive: bool = false

## 传送禁用状态
## 是否禁用传送功能，true时无法被其他传送点传送到此处
@export var transport_disable: bool = false

## 地图导出启用
## 是否将传送点导出到地图系统，true时可被其他地图直接引用
@export var enable_export_to_map: bool = false


@export_group("传送点的依赖")

## 交互组件
## 负责处理玩家与传送点的交互
@export var c_interactable: CInteractable

## 传送交互
## 具体的传送交互逻辑实现
@export var interaction_transport: InteractionTransport

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
	if transport_disable:
		type = InteractionRecord.InteractType.Null
	# 动态加入传送交互
	c_interactable.interactions_resources.append(InteractionRecord.new(type, interact_is_passive, main_control.get_path(), interaction_transport.get_path()))

	await c_interactable._initialize(self)
	# interaction_transport的数据信息设置

	interaction_transport.target_map_path = target_map_path if transport_point_type == TransportPointType.MAP else ""
	if transport_point_type == TransportPointType.LEVEL:
		interaction_transport.target_level_index = target_level_index
		interaction_transport.target_level_name = target_level_name
	else:
		interaction_transport.target_level_index = -1
		interaction_transport.target_level_name = &""
	interaction_transport.target_key = target_transport_point_key

	initialize_complete.emit()

## 传送点更新—传送点的每帧更新逻辑，当前无特殊处理
## [param _delta]: 帧时间间隔
func _update(_delta: float) -> void:
	pass

## 传送点固定更新—传送点的固定时间间隔更新，当前无特殊处理
## [param _delta]: 固定时间间隔
func _fixed_update(_delta: float) -> void:
	pass

## 属性验证—根据传送点类型动态控制编辑器中显示的属性
## [param property]: 属性信息字典
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
