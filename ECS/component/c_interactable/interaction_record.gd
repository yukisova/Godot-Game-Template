## 交互记录资源 - 存储交互配置信息的数据结构
## 该资源类用于配置和存储交互的各种参数，包括交互类型、触发方式、交互对象引用等信息
## 交互类型说明：Null禁用的交互、BodyEntered刚体进入触发交互、AreaEntered区域进入触发交互、RayCasted射线检测触发交互
## 功能特性：可视化编辑器配置、动态属性验证、NodePath引用管理、交互模式切换
## 应用场景：NPC对话交互配置、物品拾取交互设置、机关触发器配置、区域检测系统设置
## 架构设计：继承自Resource基类，使用@tool支持编辑器预览，基于enum InteractType的交互类型管理
## [br][b]编辑者:[/b] Sora
@tool
class_name InteractionRecord
extends Resource

## 交互类型枚举
## 定义不同的交互触发方式和检测机制
enum InteractType { 
	Null = -1,        ## 禁用交互
	BodyEntered = 0,  ## 刚体进入触发
	AreaEntered,      ## 区域进入触发
	RayCasted         ## 射线检测触发
}

## 是否为被动交互
## true自动触发交互，false需要玩家按键确认
@export var is_passive: bool

## 交互类型
## 决定交互的触发方式和检测机制
@export var interact_type: InteractType = InteractType.BodyEntered:
	set(v):
		interact_type = v
		notify_property_list_changed()

## 交互逻辑节点路径
## 指向Interaction类型的节点，定义交互的具体逻辑实现
@export_node_path("IInteraction") var interaction: NodePath

## 交互检测区域节点路径
## 指向InteractBox类型的节点，定义交互的触发区域范围
@export_node_path("InteractBox") var interact_box: NodePath

## 构造函数—创建新的交互记录，设置初始配置参数
## [param _interact_type]: 交互类型
## [param _is_passive]: 是否为被动交互
## [param _interact_box]: 交互检测区域的节点路径
## [param _interaction]: 交互逻辑的节点路径
func _init(_interact_type: InteractType = InteractType.BodyEntered, _is_passive: bool = false, _interact_box: NodePath = NodePath(), _interaction: NodePath = NodePath()) -> void:
	interact_type = _interact_type
	is_passive = _is_passive
	interact_box = _interact_box
	interaction = _interaction

## 属性验证—根据交互类型动态调整编辑器中显示的属性
## [param property]: 属性字典，包含属性的元数据信息
func _validate_property(property: Dictionary) -> void:
	# 射线交互不需要交互盒子，隐藏该属性
	if interact_type == InteractType.RayCasted:
		if property.name == "interact_box":
			property.usage = PROPERTY_USAGE_NO_EDITOR
