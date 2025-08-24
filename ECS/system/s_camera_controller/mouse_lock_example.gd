## 鼠标固定模式使用示例
## 展示如何在游戏中使用ViewportManager的鼠标固定功能
## [br][b]编辑者:[/b] Sora
extends Node

## 视口管理器引用
var viewport_manager: ViewportManager

## 游戏状态
enum GameState {
	MENU,       # 菜单状态
	PLAYING,    # 游戏进行中
	PAUSED      # 暂停状态
}

var current_state: GameState = GameState.MENU

func _ready():
	# 等待系统初始化
	await get_tree().process_frame
	
	# 获取视口管理器引用
	viewport_manager = get_node_or_null("/root/SCameraController/ViewportManager")
	if not viewport_manager:
		push_error("无法找到ViewportManager")
		return
	
	print("鼠标固定模式示例已加载")
	print("按空格键开始/暂停游戏")
	print("按F1键切换鼠标模式")

func _input(event: InputEvent):
	if not viewport_manager:
		return
	
	# 空格键切换游戏状态
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_SPACE:
		toggle_game_state()
	
	# 在游戏进行中处理鼠标输入
	if current_state == GameState.PLAYING:
		handle_game_input(event)

## 切换游戏状态
func toggle_game_state():
	match current_state:
		GameState.MENU:
			start_game()
		GameState.PLAYING:
			pause_game()
		GameState.PAUSED:
			resume_game()

## 开始游戏
func start_game():
	current_state = GameState.PLAYING
	print("游戏开始 - 启用鼠标锁定模式")
	
	# 启用鼠标锁定模式
	viewport_manager.enable_mouse_lock()
	
	# 隐藏鼠标光标
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

## 暂停游戏
func pause_game():
	current_state = GameState.PAUSED
	print("游戏暂停 - 释放鼠标锁定")
	
	# 释放鼠标锁定
	viewport_manager.disable_mouse_lock()
	
	# 显示鼠标光标
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

## 恢复游戏
func resume_game():
	current_state = GameState.PLAYING
	print("游戏恢复 - 重新启用鼠标锁定模式")
	
	# 重新启用鼠标锁定模式
	viewport_manager.enable_mouse_lock()
	
	# 隐藏鼠标光标
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

## 处理游戏中的输入
func handle_game_input(event: InputEvent):
	if event is InputEventMouseMotion:
		# 获取鼠标在第一个视口中的位置
		var mouse_pos = viewport_manager.get_mouse_position_in_first_viewport()
		
		# 模拟游戏逻辑：根据鼠标位置移动玩家或瞄准
		handle_mouse_movement(mouse_pos)
	
	elif event is InputEventMouseButton and event.is_pressed():
		# 处理鼠标点击
		if event.button_index == MOUSE_BUTTON_LEFT:
			handle_mouse_click()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			handle_mouse_right_click()

## 处理鼠标移动
func handle_mouse_movement(mouse_pos: Vector2):
	# 这里可以添加实际的游戏逻辑
	# 例如：移动玩家、旋转相机、瞄准等
	
	# 示例：打印鼠标位置（实际游戏中应该移除）
	if Engine.get_frames_drawn() % 60 == 0:  # 每秒打印一次
		print("鼠标位置: ", mouse_pos)

## 处理鼠标左键点击
func handle_mouse_click():
	print("鼠标左键点击 - 执行主要动作")
	# 这里可以添加射击、攻击等逻辑

## 处理鼠标右键点击
func handle_mouse_right_click():
	print("鼠标右键点击 - 执行次要动作")
	# 这里可以添加瞄准、特殊技能等逻辑

## 游戏结束时的清理
func _exit_tree():
	if viewport_manager:
		# 确保在游戏结束时释放鼠标锁定
		viewport_manager.disable_mouse_lock()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		print("游戏结束 - 鼠标锁定已释放")



