## 导航组件 - 为实体提供AI寻路和导航能力
##
## 该组件基于Godot的 [NavigationAgent2D] 系统实现智能寻路功能，
## 主要用于敌人AI、友方单位和NPC的自动移动和路径规划。
##
## 导航类型：
## - [constant NavigationType.STOP]：停止导航
## - [constant NavigationType.PAUSE]：暂停导航（保持当前目标）
## - [constant NavigationType.TRACK]：跟踪目标（动态更新目标位置）
## - [constant NavigationType.LOCATED]：定点导航（导航到固定位置）
##
## 功能特性：
## - 多重导航代理支持
## - 动态路径规划
## - 障碍物避让
## - 目标跟踪
## - 导航状态管理
##
## [br][b]编辑者:[/b] Sora
@tool
class_name CNavigation
extends IComponent

## 导航类型枚举
## 
## 定义不同的导航行为模式，用于控制AI的移动策略。
enum NavType { 
	STOP,      ## 停止导航 - 完全停止导航行为
	PAUSE,     ## 暂停导航 - 保持当前目标但暂停移动
	TRACK,     ## 跟踪导航 - 持续跟踪动态目标
	LOCATED    ## 定点导航 - 导航到固定位置
}

## 当前导航状态
## 记录实体当前的导航行为类型
var current_nav = NavType.STOP

## 导航目标位置
## 当前导航的目标位置
var target_position: Vector2

## 导航目标实体
## 用于跟踪导航的目标实体（支持所有IEntity的子类）
var target_entity: IEntity

@export_subgroup("导航依赖")
## 主要导航代理
## 用于执行寻路计算的主要NavigationAgent2D
@export var nav_agent: NavigationAgent2D

## 额外导航代理资源
## 可选的额外导航代理，用于复杂的导航场景
@export var nav_agent_resource: Array[NavigationAgent2D]

func _enter_tree() -> void:
	component_name = ComponentName.C_NAVIGATION

## 组件初始化
## 
## 设置导航代理的基本配置，连接必要的信号。
## [param _owner]: 拥有此组件的实体，必须是 [IEntity] 类型
## [param _load_data]: 可选的加载数据，用于恢复保存的状态
func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)
	
	# 配置主导航代理，连接速度计算和目标到达信号
	if nav_agent:
		nav_agent.velocity_computed.connect(_on_velocity_computed)
		nav_agent.target_reached.connect(_on_target_reached)
	
	initialize_complete.emit()

## 设置导航目标位置
## 
## 设置AI要导航到的固定位置坐标。
## [param position]: 目标位置的世界坐标
func set_target_position(position: Vector2):
	target_position = position
	current_nav = NavType.LOCATED
	
	if nav_agent:
		nav_agent.target_position = position

## 设置跟踪目标实体
## 
## 设置AI要持续跟踪的目标实体。
## [param entity]: 要跟踪的目标实体，必须是 [IEntity] 类型
func set_target_entity(entity: IEntity):
	target_entity = entity
	current_nav = NavType.TRACK

## 开始导航
## 启动导航行为
func start_navigation():
	if current_nav == NavType.STOP:
		current_nav = NavType.LOCATED

## 暂停导航
## 暂停当前的导航行为
func pause_navigation():
	if current_nav != NavType.STOP:
		current_nav = NavType.PAUSE

## 停止导航
## 完全停止导航行为
func stop_navigation():
	current_nav = NavType.STOP
	if nav_agent:
		nav_agent.target_position = component_owner.global_position

## 导航更新
## 
## 每帧更新导航逻辑，根据导航类型执行不同的更新策略。
## [param _delta]: 帧时间间隔，用于时间相关的计算
func _update(_delta: float):
	match current_nav:
		NavType.TRACK:
			_update_tracking_navigation()
		NavType.LOCATED:
			_update_location_navigation()

## 更新跟踪导航
## 
## 持续更新跟踪目标的位置，确保AI始终朝着目标移动。
func _update_tracking_navigation():
	if target_entity and nav_agent:
		nav_agent.target_position = target_entity.global_position

## 更新定点导航
## 
## 检查是否已到达目标位置，到达后自动停止导航。
func _update_location_navigation():
	if nav_agent and nav_agent.is_navigation_finished():
		current_nav = NavType.STOP

## 速度计算完成回调
## 
## 当导航代理计算出安全速度后调用，应用速度到实体移动。
## [param safe_velocity]: 导航代理计算出的安全移动速度
func _on_velocity_computed(safe_velocity: Vector2):
	# 应用安全速度到实体移动
	if component_owner.has_method("set_velocity"):
		component_owner.set_velocity(safe_velocity)

## 目标到达回调
func _on_target_reached():
	current_nav = NavType.STOP
	print("导航组件: 实体 ", component_owner.name, " 已到达目标位置")
	
