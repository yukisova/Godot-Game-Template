## - 继承自 [StatePda] 基类
## - 使用 [annotation @tool] 支持编辑器预览
## - 与导航系统和视觉系统集成
## - 支持中断和恢复的PDA机制
##
## [br][b]编辑者:[/b] Sora 
@tool
extends StatePda

@export var c_navigation: CNavigationAgent
@export var sight_box: SightBox
@export var chasing_speed: int = 3000
@export var attackable_distance: int = 100


var velocity_computed_enable: bool
var update_timer: Timer

func _enter_tree() -> void:
	keyword = "target_chasing"

func _ready() -> void:
	if (Engine.is_editor_hint()): return
	c_navigation.nav_agent.velocity_computed.connect(_on_safe_velocity_computed)
	update_timer = Timer.new()
	add_child(update_timer)
	update_timer.wait_time = 0.2
	update_timer.timeout.connect(_on_update_chasing_path)

## 安全的位移力，处理导航代理计算出的安全速度并应用到角色移动
func _on_safe_velocity_computed(safe_velocity: Vector2):
	var character = c_navigation.component_body as CharacterBody2D
	if velocity_computed_enable:
		character.velocity = safe_velocity
	else:
		character.velocity = Vector2.ZERO
	character.move_and_slide()

## 敌人开始追击玩家，此时sightbox里是有人的
func _enter():
	_on_update_chasing_path(sight_box.sight_target_last_position)
	update_timer.start()
	velocity_computed_enable = true
	print("哥布林开始追击")

func _update(_delta: float) -> void:
	var current_global_position = c_navigation.component_owner.main_control.global_position
	if sight_box.sight_target.size() > 1:
		var distance = sight_box.sight_target[-1].global_position.distance_to(current_global_position)
		if distance < attackable_distance:
			plus_trigger = 0
		
func _fixed_update(_delta: float) -> void:
	if c_navigation.nav_agent.is_navigation_finished():
		return
	
	var target_position: Vector2 = c_navigation.nav_agent.get_next_path_position()
	var target_direction: Vector2 = c_navigation.component_body.global_position.direction_to(target_position).normalized()
	var _owner_body = c_navigation.component_owner.main_control as CharacterBody2D
	var _velocity = target_direction * chasing_speed * _delta
	
	if c_navigation.nav_agent.avoidance_enabled:
		c_navigation.nav_agent.velocity = _velocity
	else:
		_owner_body.velocity = _velocity
		_owner_body.move_and_slide()
	

func _exit():
	update_timer.stop()
	velocity_computed_enable = false

func _on_update_chasing_path(target_position: Vector2 = Vector2(INF, INF)):
	if target_position != Vector2(INF , INF):
		c_navigation.nav_agent.target_position = target_position
	
	if !sight_box.sight_target.is_empty():
		c_navigation.nav_agent.target_position = sight_box.sight_target[-1].global_position
	else: 
		c_navigation.nav_agent.target_position = sight_box.sight_target_last_position
	
func _pause():
	velocity_computed_enable = false

func _continue():
	velocity_computed_enable = true

func _blur_update(_delta: float) -> void:
	pass
