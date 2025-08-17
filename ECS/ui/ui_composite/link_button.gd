## 链接按钮 - 用于界面跳转和窗口管理的专用按钮
##
## 该按钮提供两种界面操作模式：
## - Creation模式：动态创建新的UI界面
## - Linkage模式：链接到已存在的UI组件
##
## 主要功能：
## - 智能的UI界面管理
## - 动态场景实例化
## - 编辑器属性的条件显示
## - 目标界面的生命周期管理
##
## 使用场景：
## - 主菜单的设置按钮
## - 游戏内的子界面调用
## - 模态对话框的打开
## - 多窗口应用的界面切换
##
## 架构设计：
## - 继承自 [Button] 基类
## - 基于 [enum LinkMode] 的模式管理
## - 与 [PackedScene] 和 [Control] 集成
## - 支持 [CreationCanvas] 生命周期管理
##
## 编辑器集成：
## - [annotation @tool] 标记支持编辑器预览
## - 条件属性显示优化工作流
## - 实时的模式切换反馈
##
## [br][b]编辑者:[/b] Sora
@tool
class_name LinkageButton
extends Button

#region 链接模式配置

## 链接模式枚举
## 
## 定义按钮的操作方式。
enum LinkMode { 
	creation,  ## 创建模式 - 动态生成新的UI界面
	linkage    ## 链接模式 - 聚焦到已存在的目标组件
}

## 当前链接模式
## 
## 决定按钮点击时的行为方式，类型为 [enum LinkMode]。
@export var link_mode: LinkMode:
	set(v):
		link_mode = v
		notify_property_list_changed()  # 刷新编辑器属性面板

#endregion

#region Creation模式配置

## 生成器场景
## 
## Creation模式下要实例化的场景文件，类型为 [PackedScene]。
@export var generator_scene: PackedScene

## 生成场景的父节点
## 
## 新实例化的场景将添加到此节点下，类型为 [Node]。
@export var g_scene_parent: Node

#endregion

#region Linkage模式配置

## 链接控制组件
## 
## Linkage模式下要操作的目标控件，类型为 [Control]。
@export var link_control: Control

#endregion

#region 运行时数据

## 链接目标引用
## 
## Creation模式下创建的界面实例，类型为 [CreationCanvas]。
var linkage_target: CreationCanvas = null

#endregion

#region 按钮执行逻辑

## 执行按钮功能
## 根据当前模式执行相应的界面操作
func _execute():
	match link_mode:
		LinkMode.linkage:
			# TODO: 实现链接到已存在组件的逻辑
			if link_control:
				print("链接按钮: 聚焦到目标控件 -> ", link_control.name)
			else:
				push_warning("链接按钮: 目标控件未设置")
			
		LinkMode.creation:
			# 创建新的UI界面实例
			if generator_scene and g_scene_parent:
				linkage_target = generator_scene.instantiate()
				g_scene_parent.add_child(linkage_target)
				print("链接按钮: 创建新界面 -> ", linkage_target.name)
			else:
				push_error("链接按钮: 生成器场景或父节点未设置")

#endregion

#region 编辑器集成

## 验证属性显示
## 
## 根据当前模式动态显示相关属性。
## [param property]: 属性字典，类型为 [Dictionary]
func _validate_property(property: Dictionary) -> void:
	match link_mode:
		LinkMode.linkage:
			# 链接模式下隐藏创建相关属性
			if property.name == "generator_scene" or property.name == "g_scene_parent":
				property.usage = PROPERTY_USAGE_NO_EDITOR
				
		LinkMode.creation:
			# 创建模式下隐藏链接相关属性
			if property.name == "link_control":
				property.usage = PROPERTY_USAGE_NO_EDITOR

#endregion
