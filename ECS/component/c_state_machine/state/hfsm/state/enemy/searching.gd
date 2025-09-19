## 敌人搜索状态 - 敌人AI的目标搜索和确认行为
##
## 该状态在敌人注意到玩家后激活，尝试进行进一步的确认和搜索。
## 提供完整的搜索逻辑和目标跟踪机制。

@tool
extends StateHfsm

##
## 核心功能：
## - 目标的深度搜索和确认
## - 视线检测的持续监控
## - 搜索行为的定时管理
## - PDA状态栈的智能控制
##
## 搜索机制：
## - 基于 [SightBox] 的视线检测
## - 定时器控制的搜索持续时间
## - 目标确认的等待时间调整
## - 搜索失败的状态回退
##
## 目标跟踪：
## - 丢失目标时的延长搜索
## - 重新发现目标时的快速确认
## - 不同搜索阶段的时间配置
## - 搜索完成的状态转换
##
## 状态转换：
## - 目标确认成功转入战斗状态
## - 搜索超时返回巡逻状态
## - 目标丢失的延长搜索处理
## - 搜索过程的动态调整
##
## 架构设计：
## - 继承自 [StateHfsm] 基类
## - 使用 [annotation @tool] 支持编辑器功能
## - 集成 [SightBox] 视线检测系统
## - 基于定时器的搜索管理
##
## [br][b]编辑者:[/b] Sora

## 视线检测盒
## 
## 用于检测视野内目标的组件，类型为 [SightBox]。
@export var sight_box: SightBox

## 空闲状态定时器
## 
## 控制搜索持续时间的定时器，类型为 [Timer]。
var idle_state_timer: Timer

## 状态设置（重写方法）
## 
## 初始化搜索状态的视线检测和定时器组件。
func _setup():
	super()
	sight_box.target_losed.connect(_on_target_losed)
	sight_box.target_noticed.connect(_on_target_noticed)
	
	idle_state_timer = Timer.new()
	idle_state_timer.one_shot = true
	idle_state_timer.timeout.connect(_on_try_searching)
	add_child(idle_state_timer)

## 目标丢失处理
## 
## 当视野内没有目标时推送延长搜索状态。
func _on_target_losed():
	if belong_state_machine.current_state == self:
		var target_state = confirm_pda_state_dict["target_lost"]
		target_state.state_context["wait_time"] = 30
		state_pushed.emit(target_state)

## 目标发现处理
## 
## 当视野内出现目标时推送快速确认状态。
func _on_target_noticed():
	if belong_state_machine.current_state == self:
		var target_state = confirm_pda_state_dict["target_lock"]
		target_state.state_context["wait_time"] = 2
		state_pushed.emit(target_state)

## 尝试搜索处理
## 
## 定时器到期时的搜索行为，当前为空实现。
func _on_try_searching():
	pass

func _blur_update(_delta: float) -> void:
	pass

func _pause() -> void:
	pass

func _continue() -> void:
	pass	

func _update(_delta: float) -> void:
	pass

func _fixed_update(_delta: float) -> void:
	pass

func _exit() -> void:
	pass

func _enter() -> void:
	pass
