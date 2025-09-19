## 主菜单UI - 游戏的主要入口界面
##
## 该UI提供游戏的所有主要入口功能：
## - 开始新游戏和继续游戏
## - 加载已保存的游戏存档
## - 进入游戏设置界面
## - 退出游戏应用程序
##
## 主要特性：
## - 自动播放主菜单背景音乐
## - 平滑的淡入动画效果
## - 状态机集成的游戏流程控制
## - 模块化的按钮事件处理
##
## 界面功能：
## - 继续游戏：恢复上次游戏进度
## - 测试游戏：快速进入测试模式
## - 开始游戏：创建新的游戏流程
## - 加载游戏：从存档文件恢复游戏
## - 游戏设置：打开配置和选项界面
## - 退出游戏：关闭应用程序
##
## 架构设计：
## - 继承自 [UIController] 基类
## - 与 [SGameState] 系统的状态机集成
## - 使用 [FuncButton] 和 [LinkageButton] 组件
## - 集成 [SAudioMaster] 音频系统
##
## [br][b]编辑者:[/b] Sora
extends UIController

## 主菜单设置
## 初始化音频、动画和按钮事件绑定
func _main_setup() -> void:
	print("主菜单UI: 开始初始化")

	ui_model._initialize({})
	ui_view._initialize({
		"ui_controller": self
	})

	_bind_model_view()
