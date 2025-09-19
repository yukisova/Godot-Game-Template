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

#region UI控件组件

@export_group("控件", "control_")

## 重试游戏按钮
## 重新开始当前关卡或重置游戏状态
@export var control_game_retry: Button

## 游戏设置按钮
## 打开设置界面进行各项配置
@export var control_game_setting: LinkageButton

## 返回菜单按钮
## 退出当前游戏返回主菜单
@export var control_return_menu: Button

#endregion

#region UI初始化

## 初始化界面信息
## @param _context: 初始化上下文数据（暂未使用）
func _initilize_info(_context: Dictionary):
	print("暂停UI: 开始初始化")
	_setup_button_events()
	print("暂停UI: 初始化完成")

## 设置按钮事件绑定
func _setup_button_events():
	# 重试游戏按钮事件
	control_game_retry.pressed.connect(func():
		print("暂停UI: 重试游戏")
		unspawn()  # 关闭暂停界面，恢复游戏
	)
	
	# 游戏设置按钮事件
	control_game_setting.pressed.connect(func():
		print("暂停UI: 打开游戏设置")
		control_game_setting._execute()
		get_child(0).hide()  # 隐藏暂停界面
		
		# 监听设置界面关闭事件
		control_game_setting.linkage_target.window_closed.connect(func():
			get_child(0).show()  # 重新显示暂停界面
			control_game_setting.linkage_target.queue_free()  # 清理设置界面
		)
	)
	
	# 返回菜单按钮事件
	control_return_menu.pressed.connect(func():
		print("暂停UI: 返回主菜单")
		
		# 验证当前状态机状态
		var main_sm_current_state = SGameState.state_machine._get_active_state()
		if main_sm_current_state is GamingChildStateMachine:
			main_sm_current_state.update_trigger = true
		else:
			push_error("暂停UI: 状态机错误，当前不在游戏子状态机中")
	)

#endregion
