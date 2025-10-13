@tool
class_name CAttacker
extends IComponent

var current_hit_effect: IHitEffect

var active_melee_hitbox: Dictionary[String, HitboxMelee]

var attack_trigger_callable: Callable
var attack_trigger_finish_callable: Callable
var attack_success_callable: Callable
var attack_failure_callable: Callable

func _enter_tree() -> void:
	component_name = ComponentName.C_ATTACKER

func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super(_owner, _load_data)

	initialize_completed.emit()
