## 
@tool
extends StatePda

@export var vector_move: MoveStrategy
@export var c_navigation: C_Navigation

## ZoneRandomPatrol状态下的随机速度
@export var walk_speed_range: Vector2 = Vector2(5, 10)

var current_speed: float

func _ready() -> void:
	if (Engine.is_editor_hint()): return
	c_navigation.nav_agent.velocity_computed.connect(_on_safe_velocity_computed)

## 安全的位移力
func _on_safe_velocity_computed(safe_velocity: Vector2):
	var character = c_navigation.component_body as CharacterBody2D
	character.velocity = safe_velocity
	character.move_and_slide()

func _enter() -> void:
	set_movement_target.call_deferred()
	
func _update(delta: float) -> void:
	super(delta)
	
func _fixed_update(delta: float) -> void:
	if c_navigation.nav_agent.is_navigation_finished():
		pop_trigger = true
		return
	
	var target_position: Vector2 = c_navigation.nav_agent.get_next_path_position()
	var target_direction: Vector2 = c_navigation.component_body.global_position.direction_to(target_position).normalized()
	var _owner_body = vector_move.binding_entity.main_control as CharacterBody2D
	var _velocity = target_direction * current_speed
	
	if c_navigation.nav_agent.avoidance_enabled:
		c_navigation.nav_agent.velocity = _velocity
	else:
		_owner_body.velocity = _velocity
		_owner_body.move_and_slide()

func _exit():
	super()

## 设置随机的移动目标：利用NavigationServer2D底层提供的获取随机点的方法
func set_movement_target() -> void:
	var nav_agent = c_navigation.nav_agent
	var target_position: Vector2 = NavigationServer2D.map_get_random_point(
		nav_agent.get_navigation_map(), 
		nav_agent.navigation_layers, 
		false)
	nav_agent.target_position = target_position
	current_speed = randf_range(walk_speed_range.x, walk_speed_range.y)
