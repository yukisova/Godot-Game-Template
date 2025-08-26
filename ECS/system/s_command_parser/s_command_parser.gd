## 命令行解析器系统 - 开发和调试时的实时命令执行工具
## 提供类似控制台的命令行界面，支持快捷键调用和实时命令执行
## 主要用于开发调试、功能测试和游戏参数修改
## [br][b]编辑者:[/b] Sora
extends ISystem

## 命令编辑器打开信号
signal command_editor_opened

## 命令编辑器关闭信号
signal command_editor_closed

## 命令输入信号
## [param text]: 用户输入的命令文本
signal command_editor_inputed(text: String)

## 命令行面板配置组
@export_group("命令行面板", "command_parser_")

## 命令行画布层
## 用于显示命令行界面的画布层
@export var command_parser_canvas: CanvasLayer

## 命令行文本编辑器
## 用户输入命令的文本编辑组件
@export var command_parser_editor: CodeEdit

@export var test: bool = false

## 设置命令行初始状态为隐藏和禁用
func _enter_tree() -> void:
	command_parser_canvas.hide()
	process_mode = Node.PROCESS_MODE_DISABLED

## 连接命令行相关的信号处理
func _setup():
	command_editor_opened.connect(_on_editor_opened)
	command_editor_closed.connect(_on_editor_closed)
	command_editor_inputed.connect(_on_parser_begin)

## 重置时关闭命令行界面
func _resetup():
	_on_editor_closed()

## 显示命令行界面并启用输入处理
func _on_editor_opened():
	command_parser_canvas.show()
	process_mode = Node.PROCESS_MODE_INHERIT
	
	# 聚焦到文本编辑器
	if command_parser_editor and is_inside_tree():
		command_parser_editor.grab_focus()
	
	print("命令行系统: 命令行已打开")

## 隐藏命令行界面并禁用输入处理
func _on_editor_closed():
	command_parser_canvas.hide()
	process_mode = Node.PROCESS_MODE_DISABLED
	
	# 清空编辑器内容
	if command_parser_editor:
		command_parser_editor.text = ""
	
	print("命令行系统: 命令行已关闭")

## 监听用户输入和命令行状态
func _process(_delta: float) -> void:
	_listen()

## 监听用户的键盘输入，处理命令执行
func _listen():
	# 检测确认键（回车）以执行命令
	if Input.is_action_just_pressed("ui_accept"):
		command_editor_inputed.emit(command_parser_editor.text)
	
	# TODO: 添加其他快捷键支持
	# 例如：ESC键关闭命令行、Tab键自动补全等

## 处理用户输入的命令文本
## [param command_text]: 用户输入的命令
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

## 处理一些基础的调试命令
## [param command]: 要执行的命令字符串
func _execute_simple_command(command: String):
	var parts : PackedStringArray = command.split(" ", false)
	if parts.is_empty():
		return
	
	var cmd: String = parts[0].to_lower().strip_edges()

	match cmd:
		"help":
			print("可用命令: help, exit, reload")
		"exit":
			command_editor_closed.emit()
		"reload":
			# TODO: 实现重载功能
			print("重载功能尚未实现")
		_:
			print("未知命令:", cmd, "(输入 'help' 查看可用命令)")
