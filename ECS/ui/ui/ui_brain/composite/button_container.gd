## 动态按钮容器 - 根据数据动态生成按钮菜单
##
## 该组件实现了动态生成的自定义弹出菜单系统。
## 根据传入的数据自动创建一组功能按钮，支持灵活的交互配置。
##
## 核心功能：
## - 根据传入的数据生成一组按钮
## - 支持自定义按钮样式和原型
## - 动态绑定按钮功能和回调
## - 自动管理按钮的生命周期
##
## 主要特性：
## - 基于 [ButtonInfo] 类的数据驱动设计
## - 支持 [FuncButton] 的动态创建
## - 灵活的按钮内容和功能配置
## - 自动的事件绑定和清理机制
##
## 使用场景：
## - 右键上下文菜单
## - 物品交互选项菜单
## - 动态功能选择界面
## - 可配置的操作面板
##
## 架构设计：
## - 继承自 [VBoxContainer] 基类
## - 基于 [class ButtonInfo] 的数据结构
## - 支持 [Button] 原型的自定义样式
## - 与 [Item] 系统的功能集成
##
## [br][b]编辑者:[/b] Sora
class_name ButtonContainer
extends VBoxContainer

## 按钮原型
## 
## 由外部传入的按钮样式模板。如果设置了，则基于此原型复制按钮样式。
## 类型为 [Button]。
@export var button_prototype: Control

func _ready() -> void:
	pass

## 按钮信息类
## 
## 封装按钮的配置数据，包括显示文本、回调函数和上下文参数。
class ButtonInfo:
	## 按钮的显示文字名称
	## 
	## 在按钮上显示的文本内容，类型为 [String]。
	var button_name: String
	
	## 按钮对应的回调方法
	## 
	## 点击按钮时调用的方法，类型为 [Callable]。
	var button_func: Callable
	
	## 按钮的上下文参数
	## 
	## 传递给回调方法的参数数组，类型为 [Array]。
	var button_context: Array
	
	## 构造函数
	## 
	## 创建新的按钮信息对象。
	## [param _button_context]: 按钮的上下文参数，类型为 [Array]
	## [param _button_func]: 按钮的回调方法，类型为 [Callable]
	## [param _button_name]: 按钮的显示名称，类型为 [String]
	func _init(_button_context: Array, _button_func: Callable, _button_name: String) -> void:
		button_context = _button_context
		button_func = _button_func
		button_name = _button_name

## 生成按钮组
## 
## 根据按钮信息数组生成对应的按钮组件。
## [param _button_info]: 按钮信息数组，类型为 [Array] of [class ButtonInfo]
## [param start_position]: 容器的起始位置，类型为 [Vector2]
func _generate(_button_info: Array[ButtonInfo],start_position: Vector2):
	global_position = start_position
	for i in _button_info:
		# 如果按钮原型为空，则默认基于按钮创建FuncButton
		if not button_prototype:
			var new_button = FuncButton.new()
			new_button.text = i.button_name
			new_button.args = i.button_context
			new_button.pressed.connect(func():
				i.button_func.callv(new_button.args)
				queue_free()
			)
			add_child(new_button)
		else:
			var new_button = button_prototype.instantiate()
			if !new_button.has_meta("button"):
				push_error("按钮原型: 按钮原型没有绑定按钮信息，这会导致按钮容器无法正常进行工作")
				new_button.queue_free()
				return


## FIXME 目前是完全基于Item构建按钮
## 从数据创建按钮信息
## 
## 静态方法，从字典数组创建按钮信息数组。
## [param data]: 包含按钮配置的字典数组，类型为 [Array] of [Dictionary]
## [param args]: 传递给按钮的参数
## [br][br][b]返回:[/b] [Array] of [class ButtonInfo] 按钮信息数组
static func get_button_info_from(data: Array[Dictionary], args) -> Array[ButtonInfo]:
	var result: Array[ButtonInfo] = []
	for i in data:
		var button_info = ButtonInfo.new(args, i[Item.STR_FUNC] as Callable, i[Item.STR_TEXT])
		result.append(button_info)
	return result
