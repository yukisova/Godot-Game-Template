## 查找确认扩展 - 处理SeekBox区域内的交互确认
##
## 该扩展监听指定的鼠标按键，检查SeekBox检测区域内的交互目标，
## 并依次触发这些目标的交互事件。采用后进先出的处理顺序。
##
## 核心功能：
## - SeekBox区域的目标检测
## - 鼠标左键的交互触发
## - 后进先出的目标处理顺序
## - 自动的目标清理机制
##
## 工作机制：
## - 监听鼠标左键按下事件
## - 检查SeekBox的查找目标列表
## - 取出列表中的最后一个目标
## - 触发目标的交互激活事件
## - 从列表中移除已处理的目标
##
## 交互顺序：
## - LIFO（Last In, First Out）：最后进入的目标优先处理
## - 适用于重叠目标的层级管理
## - 确保最上层的目标优先响应
##
## 应用场景：
## - 重叠物体的交互选择
## - 层级式UI元素的点击处理
## - 区域内多目标的交互管理
## - 点击式交互的优先级控制
##
## 架构设计：
## - 继承自 [ReactorExtension] 基类
## - 与 [SeekBox] 检测系统集成
## - 基于鼠标输入的事件驱动
## - 支持目标的动态管理
##
## [br][b]编辑者:[/b] Sora
extends ReactorExtension

## 查找盒子组件
## 
## 负责检测交互目标的区域检测组件，类型为 [SeekBox]。
@export var seek_box: SeekBox

## 监听查找确认操作（重写方法）
## 
## 检查鼠标左键点击并处理SeekBox中的交互目标。
func _listen():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if !seek_box.seek_target.is_empty():
			# 取出最后一个目标（LIFO顺序）并触发其交互
			seek_box.seek_target[-1].interact_activated.emit(c_input_reactor.component_owner)
			seek_box.seek_target.pop_back()
