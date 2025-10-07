## 输入响应扩展基类 - 为输入响应组件提供可扩展功能
## 允许添加UI触发、鼠标交互、射线交互等功能模块
## 通过组合模式实现功能的模块化和可复用性
## [br][b]编辑者:[/b] Sora
@abstract class_name ReactorExtension
extends Node

## 绑定的输入响应组件
## 扩展通过此组件访问输入状态
var c_input_reactor: CInputReactor

var extention_type: REType

enum REType {
    ACTION_INPUT,
    UI_PANEL_OPEN,
    MOVEMENT_INPUT,
    INTERACT_CONFIRM,
}

## 
@export var disabled: bool = false

## 每帧调用的输入监听逻辑
@abstract func _late_initialize()

@abstract func _listen()
