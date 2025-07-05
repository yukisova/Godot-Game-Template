@tool
extends State

@export var animated_sprite: AnimatedSprite2D
@export var c_move: IComponent
@export var c_navigation: C_Navigation

@export var walk_state_time_range: Vector2 = Vector2(3.0, 5.0)
@export var walk_speed_range: Vector2 = Vector2(5, 10)
\
var walk_transition_trigger : bool = false
var current_speed: float

func _ready() -> void:
	if (Engine.is_editor_hint()):
		return
	c_navigation.nav_agent.velocity_computed.connect(_on_safe_velocity_computed)
	

func _on_safe_velocity_computed(safe_velocity: Vector2):
	var character = c_navigation.component_body as CharacterBody2D
	character.velocity = safe_velocity
	character.move_and_slide()

func _enter() -> void:
	walk_transition_trigger = false
	set_movement_target.call_deferred()

	animated_sprite.play("walk")
	
func _update(delta: float) -> void:
	if (walk_transition_trigger):
		state_transition.emit(parent_to_self)
	
func _fixed_update(delta: float) -> void:
	if c_navigation.nav_agent.is_navigation_finished():
		#set_movement_target()
		walk_transition_trigger = true
		return
	
	var target_position: Vector2 = c_navigation.nav_agent.get_next_path_position()
	var target_direction: Vector2 = c_navigation.component_body.global_position.direction_to(target_position).normalized()
	animated_sprite.flip_h = target_direction.x < 0
	var _owner_body = c_move.component_body as CharacterBody2D
	var _velocity = target_direction * current_speed
	
	if c_navigation.nav_agent.avoidance_enabled:
		c_navigation.nav_agent.velocity = _velocity
	else:
		_owner_body.velocity = _velocity
		_owner_body.move_and_slide()

func _exit():
	animated_sprite.stop()
	walk_transition_trigger = false

func set_movement_target() -> void:
	var nav_agent = c_navigation.nav_agent
	var target_position: Vector2 = NavigationServer2D.map_get_random_point(
		nav_agent.get_navigation_map(), 
		nav_agent.navigation_layers, 
		false)
	nav_agent.target_position = target_position
	current_speed = randf_range(walk_speed_range.x, walk_speed_range.y)
