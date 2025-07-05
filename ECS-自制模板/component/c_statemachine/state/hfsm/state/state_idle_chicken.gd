@tool
extends State

@export var animated_sprite: AnimatedSprite2D
@export var c_move: IComponent
@export var idle_state_time_range: Vector2 = Vector2(3.0, 5.0)

@onready var idle_state_timer: Timer = Timer.new()
var idle_transition_trigger : bool = false

func _ready() -> void:
	if (Engine.is_editor_hint()):
		return
	idle_state_timer.one_shot = true
	idle_state_timer.timeout.connect(func():
		idle_transition_trigger = true
	)
	add_child(idle_state_timer)
	

func _enter() -> void:
	idle_state_timer.start(randf_range(idle_state_time_range.x, idle_state_time_range.y))
	animated_sprite.play("idle")
	
func _update(delta: float) -> void:
	var _vector = c_move.get("move_vector") as Vector2
	if (idle_transition_trigger):
		state_transition.emit(parent_to_self)
	
func _fixed_update(delta: float) -> void:
	pass

func _exit():
	animated_sprite.stop()
	idle_transition_trigger = false
	pass
