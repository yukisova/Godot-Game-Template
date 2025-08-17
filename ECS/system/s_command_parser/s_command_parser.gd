## 命令行解析器系统 - 开发和调试时的实时命令执行工具
## 
## 该系统提供了一个类似控制台的命令行界面，可以在游戏运行时通过
## 快捷键调出，用于执行调试命令、修改游戏状态、测试功能等。
## 主要面向开发阶段使用，为开发者提供便捷的调试工具。
## 
## 核心功能：
## - 实时命令执行：运行时执行自定义命令
## - 快捷键调用：通过热键快速打开/关闭命令行
## - 输入处理：解析和执行用户输入的命令
## - 调试辅助：为开发调试提供便利工具
## 
## 系统特性：
## - 非阻塞式：命令行不会影响游戏正常运行
## - 可切换状态：支持开启/关闭命令行界面
## - 输入验证：处理用户输入并进行基础验证
## - 扩展性：易于添加新的调试命令
## 
## 应用场景：
## - 开发调试：快速修改游戏参数和状态
## - 功能测试：测试特定功能和边界情况
## - 作弊代码：为测试提供便捷的游戏修改工具
## - 系统监控：查看系统状态和运行信息
## 
## 架构设计：
## - 继承自 [ISystem] 基类
## - 集成 [CanvasLayer] 的UI界面控制
## - 基于 [TextEdit] 的命令输入系统
## - 使用信号系统进行状态通知
## 
## [br][b]注意:[/b] 这是一个实验性功能，主要用于开发阶段，
## 在正式发布时可能不会包含在最终游戏中。
##
## [br][b]编辑者:[/b] Sora
extends ISystem

## 命令编辑器打开信号
## 
## 当命令行界面被打开时发出。
signal command_editor_opened

## 命令编辑器关闭信号
## 
## 当命令行界面被关闭时发出。
signal command_editor_closed

## 命令输入信号
## 
## 当用户在命令行中输入命令时发出。
## [param text]: 用户输入的命令文本，类型为 [String]
signal command_editor_inputed(text: String)

## 命令行面板配置组
@export_group("命令行面板", "command_parser_")

## 命令行画布层
## 
## 用于显示命令行界面的画布层，类型为 [CanvasLayer]。
@export var command_parser_canvas: CanvasLayer

## 命令行文本编辑器
## 
## 用户输入命令的文本编辑组件，类型为 [TextEdit]。
@export var command_parser_editor: TextEdit

## 系统初始化（重写方法）
## 
## 设置命令行初始状态为隐藏和禁用。
func _enter_tree() -> void:
	command_parser_canvas.hide()
	process_mode = Node.PROCESS_MODE_DISABLED

## 系统设置（重写方法）
## 
## 连接命令行相关的信号处理。
func _setup():
	command_editor_opened.connect(_on_editor_opened)
	command_editor_closed.connect(_on_editor_closed)
	command_editor_inputed.connect(_on_parser_begin)

## 系统重置（重写方法）
## 
## 重置时关闭命令行界面。
func _resetup():
	_on_editor_closed()

## 命令编辑器打开处理
## 
## 显示命令行界面并启用输入处理。
func _on_editor_opened():
	command_parser_canvas.show()
	process_mode = Node.PROCESS_MODE_INHERIT
	
	# 聚焦到文本编辑器
	if command_parser_editor:
		command_parser_editor.grab_focus()
	
	print("命令行系统: 命令行已打开")

## 命令编辑器关闭处理
## 
## 隐藏命令行界面并禁用输入处理。
func _on_editor_closed():
	command_parser_canvas.hide()
	process_mode = Node.PROCESS_MODE_DISABLED
	
	# 清空编辑器内容
	if command_parser_editor:
		command_parser_editor.text = ""
	
	print("命令行系统: 命令行已关闭")

## 主处理循环（重写方法）
## 
## 监听用户输入和命令行状态。
func _process(_delta: float) -> void:
	_listen()

## 输入监听
## 
## 监听用户的键盘输入，处理命令执行。
func _listen():
	# 检测确认键（回车）以执行命令
	if Input.is_action_just_pressed("ui_accept"):
		command_editor_inputed.emit(command_parser_editor.text)
	
	# TODO: 添加其他快捷键支持
	# 例如：ESC键关闭命令行、Tab键自动补全等

## 命令解析开始
## 
## 处理用户输入的命令文本。
## [param command_text]: 用户输入的命令（可选参数），类型为 [String]
## 
## [br][b]TODO:[/b] 当前实现不完整，需要进一步设计命令解析逻辑
func _on_parser_begin(command_text: String = ""):
	var text_to_parse = command_text
	if text_to_parse.is_empty() and command_parser_editor:
		text_to_parse = command_parser_editor.text
	
	if text_to_parse.is_empty():
		return
	
	print("命令行系统: 执行命令 -> ", text_to_parse)
	
	# TODO: 实现具体的命令解析和执行逻辑
	# 例如：
	# - 解析命令参数
	# - 验证命令有效性
	# - 执行对应的调试功能
	# - 返回执行结果
	
	# 简单的命令示例（待完善）
	_execute_simple_command(text_to_parse)
	
	# 清空输入框
	if command_parser_editor:
		command_parser_editor.text = ""

## 执行简单命令
## 
## 处理一些基础的调试命令。
## [param command]: 要执行的命令字符串，类型为 [String]
func _execute_simple_command(command: String):
	var parts = command.split(" ", false)
	if parts.is_empty():
		return
	
	var cmd = parts[0].to_lower()
	
	match cmd:
		"help":
			print("可用命令: help, exit, reload")
		"exit":
			command_editor_closed.emit()
		"reload":
			# TODO: 实现重载功能
			print("重载功能尚未实现")
		_:
			print("未知命令: ", cmd, " (输入 'help' 查看可用命令)")
