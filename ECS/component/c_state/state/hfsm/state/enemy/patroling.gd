## 敌人的巡逻状态
@tool
extends StateHfsm

@export var sight_box: SightBox

@export var vector_move: MoveStrategy
@export var idle_time_range: Vector2 = Vector2(3.0, 5.0)
var idle_state_timer: Timer

func _setup():
	super()
	sight_box.target_losed.connect(_on_target_losed)
	sight_box.target_noticed.connect(_on_target_noticed)
	
	idle_state_timer = Timer.new()
	idle_state_timer.one_shot = true
	idle_state_timer.timeout.connect(_on_try_patroling)
	add_child(idle_state_timer)

func _on_target_losed(): ## 视野内没有目标时
	if belong_state_machine._get_active_state() != self: return

func _on_target_noticed(): ## 视野内出现目标时
	if belong_state_machine._get_active_state() != self: return

func _enter() -> void:
	idle_state_timer.start(randf_range(idle_time_range.x, idle_time_range.y))

func _update(_delta: float) -> void:
	var _vector = vector_move.get("move_vector") as Vector2

func _fixed_update(_delta: float) -> void:
	pass

func _on_try_patroling():
	
	pass
