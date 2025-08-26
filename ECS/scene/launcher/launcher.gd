## 游戏启动器 - 管理游戏的启动模式和主进程初始化
## 该启动器提供了灵活的游戏启动管理：主游戏模式（完整的游戏体验流程）和测试游戏模式（开发调试的快速启动）
## 主要功能：模式选择和场景管理、静态引用的全局访问、编辑器集成的属性管理、运行时的动态场景加载
## 使用场景：游戏发布版本的入口点、开发测试的快速启动器、多版本构建的统一管理
## 编辑器集成：@tool标记支持编辑器操作、条件属性显示优化工作流、实时模式切换和预览
## 架构设计：基于enum GameMode的模式切换、静态引用提供全局访问、与Main场景的动态加载集成
## [br][b]编辑者:[/b] Sora
@tool
class_name Launcher
extends Node

#region 游戏模式配置

## 游戏模式枚举
## 定义不同的启动和运行模式，用于切换游戏的运行环境
enum GameMode {
	FIRST_ENTER = 0,       ## 第一次进入游戏
	RETURN_TO_MENU,  ## 返回菜单模式
}


#endregion

#region 场景配置

## 主游戏场景
## 正式游戏的完整场景，包含所有系统和功能
@export var main_game: PackedScene

#endregion

#region 静态引用

## 主游戏进程静态引用
## 提供全局访问的游戏主进程实例
static var main: Main
static var mode: GameMode = GameMode.FIRST_ENTER
#endregion

#region 启动器生命周期

## 启动器初始化—根据设定的模式加载对应的游戏场景
func _ready() -> void:

	RenderingServer.set_default_clear_color(Color.BLACK)
	
	# 编辑器模式下不执行运行时逻辑
	if Engine.is_editor_hint():
		return
	
	# 加载主游戏场景
	main = main_game.instantiate()
	# 将主进程添加到场景树
	add_child(main)

#endregion
