## 小鸡空闲状态 - 小鸡NPC的待机行为状态
##
## 该状态处理小鸡NPC的待机行为，包括播放空闲动画、
## 随机等待时间、以及状态转换控制。
##
## 状态特性：
## - 播放空闲待机动画
## - 随机的待机时间间隔
## - 基于计时器的状态转换
## - 支持动画控制集成
##
## 转换机制：
## - 通过计时器控制状态持续时间
## - 随机时间范围内的待机
## - 计时器结束后触发状态转换
##
## 应用场景：
## - NPC的自然行为模拟
## - 环境氛围营造
## - 可爱的装饰性角色
##
## 架构设计：
## - 继承自 [StateHfsm] 基类
## - 使用 [annotation @tool] 支持编辑器预览
## - 集成 [AnimatedSprite2D] 动画播放
## - 基于 [Timer] 的状态转换控制
##
## [br][b]注意:[/b] 可以考虑用PDA状态来代替，实现更灵活的状态管理
##
## [br][b]编辑者:[/b] Sora
@tool
extends StateHfsm

## 动画精灵组件
## 
## 用于播放小鸡的各种动画，类型为 [AnimatedSprite2D]。
@export var animated_sprite: AnimatedSprite2D

## 移动策略组件
## 
## 用于获取移动相关信息，类型为 [IUpdateAction]。
@export var vector_move: IUpdateAction

## 空闲状态时间范围
## 
## 定义空闲状态的持续时间范围（秒），会在这个范围内随机选择。
@export var idle_state_time_range: Vector2 = Vector2(3.0, 5.0)

## 空闲状态计时器
## 
## 控制空闲状态持续时间的计时器，类型为 [Timer]。
@onready var idle_state_timer: Timer = Timer.new()

## 空闲转换触发器
## 
## 控制状态转换的触发标志。
var idle_transition_trigger : bool = false

## 节点初始化（重写方法）
## 
## 设置计时器并连接超时信号。
func _ready() -> void:
	if (Engine.is_editor_hint()):
		return
	
	# 设置计时器为单次触发
	idle_state_timer.one_shot = true
	
	# 连接超时信号，设置转换触发器
	idle_state_timer.timeout.connect(func():
		idle_transition_trigger = true
	)
	
	add_child(idle_state_timer)

## 进入空闲状态（重写方法）
## 
## 开始播放空闲动画并启动随机时间的计时器。
func _enter() -> void:
	# 在指定范围内随机选择空闲时间
	var idle_time = randf_range(idle_state_time_range.x, idle_state_time_range.y)
	idle_state_timer.start(idle_time)
	
	# 播放空闲动画
	animated_sprite.play("idle")
	print("小鸡状态: 进入空闲状态，持续时间: ", idle_time, "秒")

## 状态更新（重写方法）
## 
## 检查转换触发器，决定是否进行状态转换。
## [param delta]: 帧时间间隔
func _update(delta: float) -> void:
	# 获取移动向量（用于未来的状态转换逻辑）
	var _vector = vector_move.get("move_vector") as Vector2
	
	# 检查是否需要转换状态
	if (idle_transition_trigger):
		var next_state = get_transition_state()
		if next_state:
			state_transition.emit(next_state)

## 固定更新（重写方法）
## 
## 空闲状态的物理更新，当前为空实现。
## [param delta]: 物理帧时间间隔
func _fixed_update(delta: float) -> void:
	# 空闲状态不需要物理更新
	pass

## 退出空闲状态（重写方法）
## 
## 停止动画播放并重置转换触发器。
func _exit():
	# 停止动画播放
	animated_sprite.stop()
	
	# 重置转换触发器
	idle_transition_trigger = false
	
	print("小鸡状态: 退出空闲状态")
