## 小鸡行走状态 - 小鸡NPC的随机游走行为状态
##
## 该状态处理小鸡NPC的行走行为，集成了导航系统实现智能路径规划和避障。
## 通过随机目标点生成和动态速度调整，营造自然的游走行为。
##
## 状态特性：
## - 智能导航和路径规划
## - 随机目标点生成
## - 动态速度调整
## - 自动避障功能
## - 动画方向控制
##
## 导航系统：
## - 基于 [NavigationServer2D] 的路径规划
## - 支持 [NavigationAgent2D] 的避障
## - 随机目标点生成算法
## - 安全速度计算
##
## 应用场景：
## - NPC的自由游走行为
## - 环境生物的模拟
## - 装饰性角色的自然行为
##
## 架构设计：
## - 继承自 [StateHfsm] 基类
## - 使用 [annotation @tool] 支持编辑器预览
## - 集成 [CNavigationAgent] 导航组件
## - 基于 [AnimatedSprite2D] 的动画控制
##
## [br][b]注意:[/b] 为了避免不同AI之间的碰撞冲突，启用了导航避障功能
##
## [br][b]编辑者:[/b] Sora
@tool
extends StateHfsm

## 动画精灵组件
## 
## 用于播放小鸡的行走动画和控制朝向，类型为 [AnimatedSprite2D]。
@export var animated_sprite: AnimatedSprite2D

## 移动策略组件
## 
## 提供移动相关的策略和信息，类型为 [IUpdateAction]。
@export var vector_move: IUpdateAction

## 导航组件
## 
## 提供智能导航和路径规划功能，类型为 [CNavigationAgent]。
@export var c_navigation: CNavigationAgent

## 行走状态时间范围
## 
## 定义单次行走的持续时间范围（秒），当前未使用，预留接口。
@export var walk_state_time_range: Vector2 = Vector2(3.0, 5.0)

## 行走速度范围
## 
## 定义行走速度的随机范围，用于每次生成目标时随机选择。
@export var walk_speed_range: Vector2 = Vector2(5, 10)

## 行走转换触发器
## 
## 控制状态转换的触发标志，当到达目标点时设置为true。
var walk_transition_trigger : bool = false

## 当前行走速度
## 
## 当前行走的实际速度，在进入状态时随机生成。
var current_speed: float

## 节点初始化（重写方法）
## 
## 连接导航代理的安全速度计算信号。
func _ready() -> void:
	if (Engine.is_editor_hint()):
		return
	
	# 连接导航代理的安全速度计算信号
	c_navigation.nav_agent.velocity_computed.connect(_on_safe_velocity_computed)

## 安全速度计算回调
## 
## 处理导航系统计算出的安全移动速度，应用避障逻辑。
## [param safe_velocity]: 经过避障计算的安全速度，类型为 [Vector2]
func _on_safe_velocity_computed(safe_velocity: Vector2):
	var character = c_navigation.component_body as CharacterBody2D
	character.velocity = safe_velocity
	character.move_and_slide()

## 进入行走状态（重写方法）
## 
## 重置转换触发器，设置随机目标并开始播放行走动画。
func _enter() -> void:
	walk_transition_trigger = false
	
	# 延迟设置移动目标，确保导航系统准备就绪
	set_movement_target.call_deferred()
	
	# 播放行走动画
	animated_sprite.play("walk")
	print("小鸡状态: 进入行走状态")

## 状态更新（重写方法）
## 
## 检查转换触发器，决定是否进行状态转换。
## [param delta]: 帧时间间隔
func _update(delta: float) -> void:
	if (walk_transition_trigger):
		var next_state = get_transition_state()
		if next_state:
			state_transition.emit(next_state)

## 固定更新（重写方法）
## 
## 处理导航移动和动画控制的物理逻辑。
## [param delta]: 物理帧时间间隔
func _fixed_update(delta: float) -> void:
	# 检查是否到达目标点
	if c_navigation.nav_agent.is_navigation_finished():
		walk_transition_trigger = true
		return
	
	# 获取下一个路径点
	var target_position: Vector2 = c_navigation.nav_agent.get_next_path_position()
	var target_direction: Vector2 = c_navigation.component_body.global_position.direction_to(target_position).normalized()
	
	# 根据移动方向调整动画朝向
	animated_sprite.flip_h = target_direction.x < 0
	
	# 计算移动速度
	var _owner_body = vector_move.component_body as CharacterBody2D
	var _velocity = target_direction * current_speed
	
	# 根据是否启用避障选择移动方式
	if c_navigation.nav_agent.avoidance_enabled:
		# 使用导航代理的避障系统
		c_navigation.nav_agent.velocity = _velocity
	else:
		# 直接移动，不考虑避障
		_owner_body.velocity = _velocity
		_owner_body.move_and_slide()

## 退出行走状态（重写方法）
## 
## 停止动画播放并重置转换触发器。
func _exit():
	# 停止动画播放
	animated_sprite.stop()
	
	# 重置转换触发器
	walk_transition_trigger = false
	
	print("小鸡状态: 退出行走状态")

## 设置随机移动目标
## 
## 利用 [NavigationServer2D] 底层提供的获取随机点的方法生成目标位置。
## 同时为本次移动随机选择一个速度值。
func set_movement_target() -> void:
	var nav_agent = c_navigation.nav_agent
	
	# 获取导航地图上的随机点作为目标
	var target_position: Vector2 = NavigationServer2D.map_get_random_point(
		nav_agent.get_navigation_map(), 
		nav_agent.navigation_layers, 
		false)
	
	# 设置目标位置
	nav_agent.target_position = target_position
	
	# 随机生成本次行走的速度
	current_speed = randf_range(walk_speed_range.x, walk_speed_range.y)
	
	print("小鸡行走: 设置新目标 ", target_position, " 速度: ", current_speed)
