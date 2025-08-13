## @editing: Sora [br]
## @describe: 交互记录资源 - 存储交互配置信息的数据结构
## 
## 该资源类用于配置和存储交互的各种参数，包括交互类型、
## 触发方式、交互对象引用等信息。支持编辑器可视化配置。
## 
## 交互类型说明：
## - Null: 禁用的交互（-1）
## - BodyEntered: 刚体进入触发交互（0）
## - AreaEntered: 区域进入触发交互（1）
## - RayCasted: 射线检测触发交互（2）
## 
## 功能特性：
## - 可视化编辑器配置
## - 动态属性验证
## - 节点路径引用
## - 交互模式切换
@tool
class_name InteractionRecord
extends Resource

## 交互类型枚举
## 定义不同的交互触发方式
enum InteractType { 
	Null = -1,        ## 禁用交互
	BodyEntered = 0,  ## 刚体进入触发
	AreaEntered,      ## 区域进入触发
	RayCasted         ## 射线检测触发
}

## 是否为被动交互
## true: 自动触发交互，false: 需要玩家按键确认
@export var is_passive: bool

## 交互类型
## 决定交互的触发方式和检测机制
@export var interact_type: InteractType:
	set(v):
		interact_type = v
		notify_property_list_changed()

## 交互逻辑节点路径
## 指向PassiveInteraction类型的节点，定义交互的具体逻辑
@export_node_path("PassiveInteraction") var interaction: NodePath

## 交互检测区域节点路径
## 指向InteractBox类型的节点，定义交互的触发区域
@export_node_path("InteractBox") var interact_box: NodePath

## 属性验证
## 根据交互类型动态调整编辑器中显示的属性
func _validate_property(property: Dictionary) -> void:
	# 射线交互不需要交互盒子，隐藏该属性
	if interact_type == InteractType.RayCasted:
		if property.name == "interact_box":
			property.usage = PROPERTY_USAGE_NO_EDITOR
