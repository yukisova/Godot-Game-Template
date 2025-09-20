## UI界面基类 - 游戏界面系统的抽象基类
## UI基类提供了游戏中各种界面的统一框架，包括菜单、对话框、设置界面等
## 支持主运行模式和测试模式两种不同的初始化流程
## 生命周期管理：自动识别运行环境、提供统一的创建和销毁机制、支持焦点管理和输入处理
## 功能特性：双模式初始化、信号驱动的生命周期管理、上下文数据绑定、焦点状态处理
## 架构设计：基于 [CanvasLayer] 的界面层级管理，通过 [signal _unspawned] 的生命周期通知
## [br][b]编辑者:[/b] Sora
@abstract class_name UIController
extends CanvasLayer

## UI销毁信号
## 当UI被销毁时触发，通知UI管理器进行清理
signal _unspawned

## 测试模式标志
## 用于在编辑器中进行UI单元测试的标志位
@export var is_testing: bool

var ui_view: UIView
var ui_model: UIModel

func _enter_tree() -> void:
	for i in get_children():
		if i is UIView:
			ui_view = i
		elif i is UIModel:
			ui_model = i

## 根据运行环境选择不同的初始化流程
func _ready() -> void:
	if get_tree().current_scene != self:
		_main_setup()  # 主游戏运行时的初始化
	else:
		_test_setup()  # 单元测试时的初始化

## 在游戏主流程中的UI初始化逻辑，子类应重写此方法以实现具体的初始化行为
func _main_setup():
	pass

## 在单元测试环境中的UI初始化逻辑，子类应重写此方法以实现测试相关的初始化行为
func _test_setup():
	pass

## 使用上下文数据初始化UI内容
## 顺序: _initilize_info -> _enter_tree -> main_setup -> _bind_model_view -> _focus_listen
## [param _context]: 包含初始化数据的上下文字典
func _initilize_info(_context: Dictionary):
	pass

func _bind_model_view():
	pass

## 当UI获得焦点时的输入监听和处理逻辑，子类应重写此方法以实现具体的焦点处理行为
func _focus_listen():
	pass

## 触发UI销毁流程并发送相应信号
func unspawn():
	_unspawned.emit(self)
