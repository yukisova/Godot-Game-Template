## 导航组件 - 为实体提供AI寻路和导航能力
## 基于Godot的NavigationAgent2D系统实现智能寻路功能
## 使用的枚举状态机
## 允许的导航方案
## 功能特性：多代理支持、动态路径规划、障碍避让、目标跟踪
## [br][b]编辑者:[/b] Sora
@tool
class_name CNavigationAgent
extends IComponent

signal nav_type_changed(new_type: NavType)

## 导航状态
enum NavState { 
	STOP,      ## 停止导航，导航目标完全清空，
	PAUSE,     ## 暂停导航，导航目标
	RUNNING,   ## 导航正常进行
}
enum NavType {
	DIRECTIONAL, ## 
	TRACK,
	LOCATED,
}

## 当前导航的移动速度
@export var current_speed_range: Vector2 = Vector2(3000, 5000)
var current_speed: float = 0.0

var current_nav_type: NavType

## 当前导航状态，记录实体当前的导航行为类型
var current_nav_state: NavState = NavState.STOP

var velocity_computed_enable: bool = false

var target_info: Dictionary

var trace_refresh_timer: Timer

@export_group("可选依赖")
@export var move_strategy: MoveStrategyVector = null


@export_group("导航依赖")
## 主要导航代理，用于执行寻路计算
@export var nav_agent: NavigationAgent2D

func _enter_tree() -> void:
	component_name = ComponentName.C_NAVIGATION_AGENT

## 组件初始化，设置导航代理的基本配置，连接必要的信号
## [param _owner]: 拥有此组件的实体，必须是 [IEntity] 类型
## [param _load_data]: 可选的加载数据，用于恢复保存的状态
func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)
	
	# 配置主导航代理，连接速度计算和目标到达信号
	if nav_agent:
		nav_agent.velocity_computed.connect(_on_safe_velocity_computed)
		nav_agent.target_reached.connect(_on_target_reached)
		nav_type_changed.connect(_on_nav_type_changed)
	
	#region 当追踪玩家的时候专门使用的计时器
	trace_refresh_timer = Timer.new()
	trace_refresh_timer.wait_time = 0.2
	trace_refresh_timer.timeout.connect(_update_tracking_navigation)
	add_child(trace_refresh_timer)
	trace_refresh_timer.stop()
	#endregion
	
	initialize_complete.emit()

#region 设置目标的导航位置
## 设置导航目标位置，设置AI要导航到的固定位置坐标
## [param position]: 目标位置的世界坐标
func set_target_position(position: Vector2):
	target_info.clear()
	target_info.set("position", position)
	current_speed = randf_range(current_speed_range.x, current_speed_range.y)
	current_nav_state = NavState.RUNNING
	nav_type_changed.emit(NavType.LOCATED)
	if nav_agent:
		nav_agent.target_position = position
		velocity_computed_enable = true

## 设计导航目标的方向，FIXME 
func set_target_direction(direction: Vector2):
	target_info.clear()
	target_info.set("direction", direction)
	current_nav_state = NavState.RUNNING
	nav_type_changed.emit(NavType.DIRECTIONAL)
	if velocity_computed_enable:
		velocity_computed_enable = false

## 设置跟踪目标实体，设置AI要持续跟踪的目标实体
## [param entity]: 要跟踪的目标实体，必须是 [IEntity] 类型
func set_target_entity(entity: IEntity):
	target_info.clear()
	target_info.set("body", entity.main_control)
	current_nav_state = NavState.RUNNING
	nav_type_changed.emit(NavType.LOCATED)

#endregion

#region 导航的钩子
## 开始导航，启动导航行为
func start_navigation():
	if current_nav_state == NavState.STOP:
		current_nav_state = NavState.RUNNING

## 暂停导航，暂停当前的导航行为
func pause_navigation():
	if current_nav_state != NavState.STOP:
		current_nav_state = NavState.PAUSE

## 停止导航，完全停止导航行为
func stop_navigation():
	current_nav_state = NavState.STOP
	if nav_agent:
		nav_agent.target_position = component_owner.global_position
		velocity_computed_enable = false
#endregion


## 导航更新，每帧更新导航逻辑，根据导航类型执行不同的更新策略
## [param _delta]: 帧时间间隔，用于时间相关的计算
func _update(_delta: float):
	match current_nav_type:
		NavType.DIRECTIONAL:
			pass
		NavType.TRACK:
			pass
		NavType.LOCATED:
			if nav_agent.is_navigation_finished():
				nav_agent.velocity = Vector2.ZERO
			else:
				var current_position = component_body.global_position
				var target_position = nav_agent.get_next_path_position()
				var direction = current_position.direction_to(target_position).normalized()
				nav_agent.velocity = direction * current_speed * _delta
	

## 更新跟踪导航，持续更新跟踪目标的位置，确保AI始终朝着目标移动
func _update_tracking_navigation():
	var body = target_info.get("body") as Node2D
	if body and nav_agent:
		nav_agent.target_position = body.global_position

## 更新定点导航，检查是否已到达目标位置，到达后自动停止导航
func _update_location_navigation():
	if nav_agent and nav_agent.is_navigation_finished():
		current_nav_state = NavState.STOP

## 目标到达回调，当实体到达目标位置时自动停止导航
func _on_target_reached():
	if current_nav_state != NavState.STOP:
		current_nav_state = NavState.STOP

## 安全的位移力，处理导航代理计算出的安全速度并应用到角色移动
func _on_safe_velocity_computed(safe_velocity: Vector2):
	var character = component_body as CharacterBody2D
	if velocity_computed_enable:
		character.velocity = safe_velocity
		if move_strategy:
			move_strategy._set_move_vector(safe_velocity)
	else:
		character.velocity = Vector2.ZERO
		if move_strategy:
			move_strategy._set_move_vector(Vector2.ZERO)
	character.move_and_slide()

func _on_nav_type_changed(new_type: NavType):
	if current_nav_type == new_type:
		return
	trace_refresh_timer.stop()
	match new_type:
		NavType.DIRECTIONAL:
			pass
		NavType.TRACK:
			trace_refresh_timer.start()
		NavType.LOCATED:
			pass
	current_nav_type = new_type
