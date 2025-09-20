## @editing: Sora [br]
## @describe: 暂停界面UI - 游戏暂停时显示的控制面板
##
## 该UI在游戏暂停时提供玩家各种选择：
## - 重试当前关卡或场景
## - 打开游戏设置进行配置调整
## - 返回主菜单退出当前游戏
##
## 主要功能：
## - 游戏流程控制（重试、返回）
## - 设置界面的弹出管理
## - 状态机的正确状态转换
##
## 界面特性：
## - 模态对话框形式显示
## - 与设置界面的联动交互
## - 安全的状态机状态检查
extends UIController

#region UI初始化

## 初始化界面信息
## @param _context: 初始化上下文数据（暂未使用）
func _initilize_info(_context: Dictionary):
	await ready

	ui_model._initialize({})
	ui_view._initialize({
		"ui_controller": self
	})
