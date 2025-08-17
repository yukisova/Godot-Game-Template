## 敌人巡逻状态 - 敌人AI的智能巡逻和目标检测行为
##
## 该状态实现了敌人的巡逻行为，结合视线检测和移动策略，
## 提供完整的巡逻逻辑和目标发现处理。
@tool
extends StateHfsm

##
## 核心功能：
## - 智能的巡逻路径执行
## - 实时的视线目标检测
## - 动态的巡逻状态管理
## - PDA状态栈的复杂控制
##
## 巡逻机制：
## - 基于 [MoveStrategy] 的移动策略
## - 随机化的空闲时间间隔
## - 定时器控制的巡逻节奏
## - 视线检测与巡逻的结合
##
## 目标检测：
## - 巡逻过程中的持续监控
## - 目标发现时的状态转换
## - 目标丢失时的搜索逻辑
## - 不同检测情况的响应机制
##
## 状态转换：
## - 目标锁定时转入战斗状态
## - 目标丢失时推送搜索状态
## - 巡逻完成时的随机巡逻继续
## - PDA状态栈的智能管理
##
## 架构设计：
## - 继承自 [StateHfsm] 基类
## - 使用 [annotation @tool] 支持编辑器功能
## - 集成 [MoveStrategy] 移动策略系统
## - 基于 [SightBox] 的视线检测集成
##
## [br][b]编辑者:[/b] Sora

## 移动策略
## 
## 控制敌人巡逻移动的策略组件，类型为 [MoveStrategy]。
@export var vector_move: MoveStrategy

## 空闲时间范围
## 
## 巡逻间隔的随机时间范围，类型为 [Vector2]。
@export var idle_time_range: Vector2 = Vector2(3.0, 5.0)

## 空闲状态定时器
## 
## 控制巡逻节奏的定时器，类型为 [Timer]。
var idle_state_timer: Timer

## 视线检测盒
## 
## 用于检测视野内目标的组件，类型为 [SightBox]。
@export var sight_box: SightBox


## 状态设置（重写方法）
## 
## 初始化巡逻状态的视线检测和定时器组件。
func _setup():
	super()
	sight_box.target_losed.connect(_on_target_losed)
	sight_box.target_noticed.connect(_on_target_noticed)
	
	idle_state_timer = Timer.new()
	idle_state_timer.one_shot = true
	idle_state_timer.timeout.connect(_on_try_patroling)
	add_child(idle_state_timer)

## 进入巡逻状态（重写方法）
## 
## 开始随机间隔的巡逻定时器。
func _enter() -> void:
	idle_state_timer.start(randf_range(idle_time_range.x, idle_time_range.y))

## 模糊更新（重写方法）
## 
## 处理巡逻状态的更新逻辑和PDA状态栈管理。
## [param _delta]: 帧时间间隔，类型为 [float]
func _blur_update(_delta: float) -> void:
	var _vector = vector_move.move_vector as Vector2

	if pda_state_stack.size() > 1:
		var top_state = pda_state_stack[-1] as StatePda
		match top_state.keyword:
			"target_lock":
				if top_state.plus_trigger:
					state_transition.emit(get_transition_state())
			"target_lost":
				if top_state.plus_trigger:
					state_pushed.emit()
	
## 目标丢失处理
## 
## 当视野内没有目标时推送目标丢失状态。
func _on_target_losed():
	if belong_state_machine.current_state == self:
		var target_state = confirm_pda_state_dict["target_lost"]
		target_state.state_context["wait_time"] = 10
		state_pushed.emit(target_state)

## 目标发现处理
## 
## 当视野内出现目标时推送目标锁定状态。
func _on_target_noticed():
	if belong_state_machine.current_state == self:
		var target_state = confirm_pda_state_dict["target_lock"]
		target_state.state_context["wait_time"] = 4
		state_pushed.emit(target_state)

## 尝试巡逻处理
## 
## 定时器到期时触发随机巡逻行为。
func _on_try_patroling():
	if pda_state_stack.size() == 1:
		state_pushed.emit(confirm_pda_state_dict["random_patrol"])
