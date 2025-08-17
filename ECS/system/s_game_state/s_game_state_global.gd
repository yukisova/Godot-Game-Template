## @editing: Sora [br]
## @describe: 游戏状态机系统 - 管理游戏的全局状态流转
## 
## 该系统负责管理游戏的主要状态，如菜单状态、游戏状态、暂停状态等。
## 使用层次化有限状态机（HFSM）来处理复杂的状态切换逻辑。
## 
## 功能特性：
## - 全局游戏状态管理
## - 状态切换事件通知
## - 暂停/继续功能支持
## - 与其他系统的状态同步
extends ISystem

## 游戏暂停信号
## 当游戏进入暂停状态时触发，通知其他系统暂停更新
@warning_ignore("unused_signal")
signal game_paused

## 游戏继续信号  
## 当游戏从暂停状态恢复时触发，通知其他系统恢复更新
@warning_ignore("unused_signal")
signal game_continue

## 主状态机
## 管理游戏的所有状态流转，包括启动、菜单、游戏、暂停等状态
@export var state_machine: StateMachineHfsm

## 系统初始化标志
## 用于确保状态机完全初始化后才开始更新
var is_setup = false

## 系统初始化
## 设置并启动主状态机
func _setup():
	state_machine._setup()
	state_machine._enter()
	is_setup = true

## 主循环更新
## 每帧更新状态机逻辑
## @param delta: 帧时间间隔
func _process(delta: float) -> void:
	if is_setup:
		state_machine._update(delta)

## 物理更新
## 每个物理帧更新状态机的物理相关逻辑
## @param delta: 物理帧时间间隔
func _physics_process(delta: float) -> void:
	if is_setup:
		state_machine._fixed_update(delta)
