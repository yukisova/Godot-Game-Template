## 游戏进行时子状态机 - 管理游戏运行期间的各种状态
##
## 该子状态机是游戏状态系统的核心组件，负责管理游戏运行期间的各种状态切换。
## 提供完整的游戏状态管理和子系统协调功能。
##
## 核心状态：
## 1. [b]正常游戏[/b]：允许玩家操控自己的角色，进行游戏场景内的互动
## 2. [b]游戏暂停[/b]：游戏冻结，只允许UI继续运行
## 3. [b]过场剧情[/b]：播放过场动画和剧情，限制玩家操作
## 4. [b]加载状态[/b]：场景切换和资源加载的过渡状态
##
## 主要功能：
## - 统一的游戏状态管理
## - 子系统的启动和协调
## - 状态转换的触发器机制
## - UI系统的信号集成
##
## 工作机制：
## - 基于更新触发器的状态切换
## - 自动的子系统设置启动
## - 与UI主界面的信号通信
## - 状态退出的清理处理
##
## 架构设计：
## - 继承自 [StateMachineHfsm] 基类
## - 使用 [annotation @tool] 支持编辑器功能
## - 与 [SBlackboard] 子系统的集成
## - 基于 [SSignalBus] 的UI通信
##
## [br][b]编辑者:[/b] Sora

@tool
class_name GamingChildStateMachine
extends StateMachineHfsm

## 更新触发器
## 
## 用于控制状态转换的布尔标志。
var update_trigger = false

## 状态机设置（重写方法）
## 
## 初始化游戏子状态机的基础配置。
func _setup() -> void:
	super()
	

## 进入游戏状态机（重写方法）
## 
## 激活子系统并开始游戏循环。
func _enter():
	super()
	SBlackboard.sub_systems_setup_start.emit()

## 状态机更新（重写方法）
## 
## 检查更新触发器并执行状态转换。
## [param _delta]: 帧时间间隔，类型为 [float]
func _update(_delta: float) -> void:
	super._update(_delta)
	if update_trigger:
		state_transition.emit(get_transition_state())

## 退出游戏状态机（重写方法）
## 
## 清理触发器并通知UI系统返回主界面。
func _exit():
	super()
	update_trigger = false
	SSignalBus.ui_main_returned.emit()
