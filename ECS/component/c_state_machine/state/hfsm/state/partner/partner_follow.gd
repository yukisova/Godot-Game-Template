## 伙伴跟随状态 - 实现伙伴AI的智能跟随行为
##
## 该状态实现了伙伴对玩家的智能跟随功能，包括路径规划、避障和平滑移动。
## 伙伴会自动保持与玩家的适当距离，并处理复杂的导航逻辑。
##
## 核心功能：
## - 智能的玩家跟随逻辑
## - 导航系统的深度集成
## - 平滑的移动和避障
## - 动态的路径刷新机制
##
## 跟随特性：
## - 实时路径规划和更新
## - 安全速度计算和避障
## - 导航完成状态的检测
## - 跟随距离的智能控制
##
## 导航机制：
## - 基于 [NavigationAgent2D] 的路径规划
## - 定时器控制的路径刷新（0.4秒间隔）
## - 速度插值的平滑移动
## - 避障启用时的安全速度计算
##
## 应用场景：
## - 伙伴的主要行为状态
## - 队伍移动的协调
## - 复杂地形的跟随
## - 战斗中的位置保持
##
## 架构设计：
## - 继承自 [StateHfsm] 基类
## - 使用 [annotation @tool] 支持编辑器功能
## - 集成 [CNavigationAgent] 导航组件
## - 基于定时器的路径更新机制
##
## [br][b]编辑者:[/b] Sora
@tool
extends StateHfsm

## 导航组件引用
## 
## 伙伴的导航组件，用于路径规划和移动控制，类型为 [CNavigationAgent]。
var c_navigation: CNavigationAgent

## 路径刷新定时器
## 
## 控制路径更新频率的定时器，类型为 [Timer]。
var path_refresh_timer: Timer

## 速度计算启用标志
## 
## 控制是否启用速度计算的布尔值。
var velocity_computed_enable: bool = true

## 跟随速度
## 
## 伙伴跟随玩家的移动速度。
var follow_speed = 3000

## 状态设置（重写方法）
## 
## 初始化跟随状态的各种组件和连接。
func _setup():
	super()
	
	# 创建并配置路径刷新定时器
	path_refresh_timer = Timer.new()
	path_refresh_timer.wait_time = 0.4
	path_refresh_timer.one_shot = false
	add_child(path_refresh_timer)
	path_refresh_timer.timeout.connect(set_movement_target_to_player)
	
	# 获取导航组件并连接信号
	c_navigation = belong_state_machine.c_navigation
	c_navigation.nav_agent.velocity_computed.connect(_on_safe_velocity_computed)

## 进入跟随状态（重写方法）
## 
## 激活跟随行为并开始路径刷新。
func _enter():
	set_movement_target_to_player.call_deferred()
	path_refresh_timer.start()

## 固定更新（重写方法）
## 
## 执行跟随移动的核心逻辑。
## [param _delta]: 固定时间间隔，类型为 [float]
func _fixed_update(_delta: float) -> void:
	if c_navigation.nav_agent.is_navigation_finished():
		return
	
	var target_position: Vector2 = c_navigation.nav_agent.get_next_path_position()
	var target_direction: Vector2 = c_navigation.component_body.global_position.direction_to(target_position).normalized()
	var _owner_body = c_navigation.component_owner.main_control as CharacterBody2D
	var _velocity = target_direction * follow_speed * _delta
	
	if c_navigation.nav_agent.avoidance_enabled:
		c_navigation.nav_agent.velocity = _velocity
	else:
		_owner_body.velocity = _velocity
		_owner_body.move_and_slide()

## 安全速度计算回调
## 
## 处理导航系统计算的安全速度。
## [param safe_velocity]: 计算出的安全速度向量，类型为 [Vector2]
func _on_safe_velocity_computed(safe_velocity: Vector2):
	var character = c_navigation.component_body as CharacterBody2D
	if velocity_computed_enable:
		character.velocity = lerp(character.velocity, safe_velocity, 0.2)
	else:
		character.velocity = lerp(character.velocity, Vector2.ZERO, 0.2)
	character.move_and_slide()

## 设置移动目标到玩家位置
## 
## 将导航目标设置为玩家的当前位置。
func set_movement_target_to_player() -> void:
	var nav_agent = c_navigation.nav_agent
	var target_position = SMainController.player_static.main_control.global_position
	nav_agent.target_position = target_position
