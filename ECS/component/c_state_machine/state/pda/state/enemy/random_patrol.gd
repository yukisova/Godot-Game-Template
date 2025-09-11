## 随机巡逻PDA状态 - 敌人的随机巡逻行为实现
## 实现敌人在区域内的随机移动巡逻，使用导航系统避障
## 功能特性：随机目标生成、速度范围控制、导航避障、自动弹出机制
## [br][b]编辑者:[/b] Sora
@tool
extends StatePda

@export var vector_move: IUpdateAction
@export var c_navigation: CNavigationAgent

## ZoneRandomPatrol状态下的随机速度范围
@export var walk_speed_range: Vector2 = Vector2(5, 10)
var velocity_computed_enable: bool

var current_speed: float

func _enter_tree() -> void:
	keyword = "random_patrol"

func _ready() -> void:
	if (Engine.is_editor_hint()): return

func _enter() -> void:
	set_movement_target_random.call_deferred()
	print("哥布林巡逻")
	
func _fixed_update(delta: float) -> void:
	if c_navigation.nav_agent.is_navigation_finished():
		pop_trigger = true
		return
	
	var target_position: Vector2 = c_navigation.nav_agent.get_next_path_position()
	var target_direction: Vector2 = c_navigation.component_body.global_position.direction_to(target_position).normalized()
	var _owner_body = vector_move.binding_entity.main_control as CharacterBody2D
	var _velocity = target_direction * current_speed * delta
	
	if c_navigation.nav_agent.avoidance_enabled:
		c_navigation.nav_agent.velocity = _velocity
	else:
		_owner_body.velocity = _velocity
		_owner_body.move_and_slide()

func _exit():
	velocity_computed_enable = false

## 设置随机的移动目标，利用NavigationServer2D底层提供的获取随机点的方法
func set_movement_target_random() -> void:
	var nav_agent = c_navigation.nav_agent
	var target_position: Vector2 = NavigationServer2D.map_get_random_point(
		nav_agent.get_navigation_map(), 
		nav_agent.navigation_layers, 
		false)
	nav_agent.target_position = target_position
	current_speed = randf_range(walk_speed_range.x, walk_speed_range.y)
	velocity_computed_enable = true

func _pause():
	velocity_computed_enable = false

func _continue():
	velocity_computed_enable = true
