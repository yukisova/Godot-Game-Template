## 游戏状态机系统 - 管理游戏的全局状态流转
## 使用层次化有限状态机处理菜单、游戏、暂停等状态切换
## 支持状态切换事件通知和暂停/继续的游戏循环控制
## [br][b]编辑者:[/b] Sora
extends ISystem

## 主状态机
## 管理游戏的所有状态流转
@export var state_machine: StateMachine

## 系统初始化标志
## 确保状态机初始化后才开始更新
var is_setup = false

## 设置并启动主状态机
func _setup():
	state_machine._setup()
	state_machine._enter()
	is_setup = true

## 每帧更新状态机逻辑
## [param delta]: 帧时间间隔
func _process(delta: float) -> void:
	if is_setup:
		state_machine._update(delta)

## 每个物理帧更新状态机逻辑
## [param delta]: 物理帧时间间隔
func _physics_process(delta: float) -> void:
	if is_setup:
		state_machine._fixed_update(delta)
