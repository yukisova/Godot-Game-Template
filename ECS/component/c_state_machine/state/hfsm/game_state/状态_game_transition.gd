## 游戏过渡状态 - 游戏场景加载时的过渡状态实现
##
## 该状态在游戏场景加载过程中激活，负责管理加载流程和实体初始化控制。
## 当 [SMapData] 正在加载环境时，系统会按照指定次序加载内容。
##
## 状态特性：
## - 禁用实体初始化：防止加载过程中的实体创建
## - 监听加载完成信号
## - 控制加载次序和时机
## - 触发游戏循环开始
##
## 退出条件：
## 1. [SMapData] 加载完毕，并发送了相关的信号
## 2. 所有必要的初始化完成
##
## 应用场景：
## - 主菜单进入游戏的过渡期
## - 场景切换时的加载状态
## - 大型资源加载的等待状态
##
## 架构设计：
## - 继承自 [StateHfsm] 基类
## - 使用 [annotation @tool] 支持编辑器预览
## - 与 [Main] 系统集成控制实体初始化
## - 通过 [SSignalBus] 发送游戏循环信号
##
## [br][b]注意:[/b] 游戏过渡加载状态与游戏运行中加载状态应当区别开来，
## 这个状态只能用作在主菜单加载游戏的过渡状态。
##
## [br][b]编辑者:[/b] Sora
@tool
class_name GameStartTransition
extends StateHfsm

## 更新触发器
## 
## 控制状态转换的触发标志，当设置为true时将触发状态转换。
var update_trigger = false

## 进入过渡状态（重写方法）
## 
## 禁用实体初始化，防止加载过程中创建实体。
func _enter():
	Main.entity_initialzable = false

## 状态更新（重写方法）
## 
## 检查更新触发器并在满足条件时触发状态转换。
## [param _delta]: 帧时间间隔
func _update(_delta: float) -> void:
	if update_trigger:
		state_transition.emit(get_transition_state())

## 退出过渡状态（重写方法）
## 
## 重置触发器，启用实体初始化，并发送游戏循环开始信号。
func _exit():
	update_trigger = false
	Main.entity_initialzable = true
	
	await belong_state_machine.state_transition_finished
	
	var current_viewport = SViewportManager.get_first_viewport()
	current_viewport.camera_strategy = CFSAttachPlayer.new(Vector2(30, -10))
	var tween = get_tree().create_tween()
	await current_viewport.camera_strategy.tween_offset(Vector2(0, 0), 1.5, tween)
	await SViewportManager.camera_zoom_change_gradually(current_viewport, Vector2(4,4), 1.5)
	SSignalBus.game_loop_start.emit()

func _fixed_update(_delta: float) -> void:
	pass

func _blur_update(_delta: float) -> void:
	pass

func _pause() -> void:
	pass

func _continue() -> void:
	pass
