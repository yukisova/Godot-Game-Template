## 游戏启动器 - 管理游戏的启动模式和主进程初始化
##
## 该启动器提供了灵活的游戏启动管理：
## - 主游戏模式：完整的游戏体验流程
## - 测试游戏模式：开发调试的快速启动
##
## 主要功能：
## - 模式选择和场景管理
## - 静态引用的全局访问
## - 编辑器集成的属性管理
## - 运行时的动态场景加载
##
## 使用场景：
## - 游戏发布版本的入口点
## - 开发测试的快速启动器
## - 多版本构建的统一管理
##
## 编辑器集成：
## - @tool标记支持编辑器操作
## - 条件属性显示优化工作流
## - 实时模式切换和预览
##
## 架构设计：
## - 基于 [enum GameMode] 的模式切换
## - 静态引用提供全局访问
## - 与 [Main] 场景的动态加载集成
##
## [br][b]编辑者:[/b] Sora
@tool
class_name Launcher
extends Node

#region 游戏模式配置

## 游戏模式枚举
## 
## 定义不同的启动和运行模式，用于切换游戏的运行环境。
enum GameMode {
	Main_Game = 0,  ## 主游戏模式 - 完整游戏流程
	Test_Game       ## 测试模式 - 开发调试用
}

## 当前游戏模式
## 
## 决定启动哪个版本的游戏场景，影响整个游戏的运行流程。
@export var mode: GameMode:
	set(value):
		mode = value
		notify_property_list_changed()  # 刷新编辑器属性面板
	get:
		return mode

#endregion

#region 场景配置

## 主游戏场景
## 
## 正式游戏的完整场景，包含所有系统和功能。
@export var main_game: PackedScene

## 测试游戏场景
## 
## 精简的测试场景，用于快速开发和调试。
@export var test_game: PackedScene

#endregion

#region 静态引用

## 主游戏进程静态引用
## 
## 提供全局访问的游戏主进程实例，参见 [Main] 类。
static var main: Main

## 设置的游戏模式
## 
## 运行时确定的游戏模式，用于其他系统判断当前运行环境。
static var mode_setted: GameMode

#endregion

#region 启动器生命周期

## 启动器初始化
## 
## 根据设定的模式加载对应的游戏场景。
func _ready() -> void:
	# 编辑器模式下不执行运行时逻辑
	if Engine.is_editor_hint():
		return
	
	print("启动器: 开始初始化，模式: ", GameMode.keys()[mode])
	
	# 记录设置的模式
	mode_setted = mode
	
	# 根据模式实例化对应的主进程
	match mode:
		GameMode.Main_Game:
			main = main_game.instantiate()
			print("启动器: 加载主游戏场景")
		GameMode.Test_Game:
			main = test_game.instantiate()
			print("启动器: 加载测试游戏场景")
	
	# 将主进程添加到场景树
	add_child(main)
	print("启动器: 主进程启动完成")

#endregion

#region 编辑器集成

## 验证属性显示
## 
## 根据当前模式动态显示相关的场景配置。
## [param property]: 属性字典，包含属性的元数据信息
func _validate_property(property: Dictionary) -> void:
	match mode:
		GameMode.Main_Game:
			# 主游戏模式下隐藏测试场景配置
			if property.name == "test_game":
				property.usage = PROPERTY_USAGE_NO_EDITOR
		GameMode.Test_Game:
			# 测试模式下隐藏主游戏场景配置
			if property.name == "main_game":
				property.usage = PROPERTY_USAGE_NO_EDITOR

#endregion
