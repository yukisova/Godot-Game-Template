## 鼠标固定模式测试脚本
## 用于测试ViewportManager的鼠标固定功能
## [br][b]编辑者:[/b] Sora
extends Node

## 视口管理器引用
var viewport_manager: ViewportManager

func _ready():
	# 等待一帧确保所有系统都已初始化
	await get_tree().process_frame
	
	# 获取视口管理器引用
	viewport_manager = get_node_or_null("/root/SCameraController/ViewportManager")
	if not viewport_manager:
		push_error("无法找到ViewportManager")
		return
	
	print("鼠标固定模式测试脚本已加载")
	print("按F1键切换鼠标模式")
	print("按ESC键释放鼠标锁定")

func _input(event: InputEvent):
	if not viewport_manager:
		return
	
	# 测试按键
	if event is InputEventKey and event.is_pressed():
		match event.keycode:
			KEY_F2:
				# F2键启用鼠标锁定模式
				viewport_manager.enable_mouse_lock()
				print("已启用鼠标锁定模式")
			KEY_F3:
				# F3键启用鼠标限制模式
				viewport_manager.enable_mouse_confinement()
				print("已启用鼠标限制模式")
			KEY_F4:
				# F4键禁用鼠标固定模式
				viewport_manager.disable_mouse_lock()
				print("已禁用鼠标固定模式")
			KEY_F5:
				# F5键切换鼠标固定模式
				viewport_manager.toggle_mouse_lock()
				print("已切换鼠标固定模式")
			KEY_F6:
				# F6键显示当前鼠标模式
				var current_mode = viewport_manager.get_mouse_mode()
				print("当前鼠标模式: ", current_mode)
			KEY_F7:
				# F7键显示第一个视口信息
				var first_viewport = viewport_manager.get_first_viewport()
				if first_viewport:
					var rect = viewport_manager.get_first_viewport_rect()
					print("第一个视口矩形: ", rect)
					print("鼠标是否在第一个视口内: ", viewport_manager.is_mouse_in_first_viewport())
				else:
					print("没有找到第一个视口")



