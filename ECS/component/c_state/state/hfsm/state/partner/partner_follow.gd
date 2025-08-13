## 这是伙伴的跟随状态，默认会跟随玩家
@tool
extends StateHfsm

var c_navigation: CNavigation
var path_refresh_timer: Timer
var velocity_computed_enable: bool = true
var follow_speed = 3000

func _setup():
	super()
	path_refresh_timer = Timer.new()
	path_refresh_timer.wait_time = 0.4
	path_refresh_timer.one_shot = false
	add_child(path_refresh_timer)
	path_refresh_timer.timeout.connect(set_movement_target_to_player)
	
	c_navigation = belong_state_machine.c_navigation ## 应当确保状态机内存在C_Navigation引用供使用
	c_navigation.nav_agent.velocity_computed.connect(_on_safe_velocity_computed)

func _enter():
	set_movement_target_to_player.call_deferred()
	path_refresh_timer.start()

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

func _on_safe_velocity_computed(safe_velocity: Vector2):
	var character = c_navigation.component_body as CharacterBody2D
	if velocity_computed_enable:
		character.velocity = lerp(character.velocity, safe_velocity, 0.2)
	else:
		character.velocity = lerp(character.velocity, Vector2.ZERO, 0.2)
	character.move_and_slide()

## 设置随机的移动目标：利用NavigationServer2D底层提供的获取随机点的方法
func set_movement_target_to_player() -> void:
	var nav_agent = c_navigation.nav_agent
	var target_position = SMainController.player_static.main_control.global_position
	nav_agent.target_position = target_position
