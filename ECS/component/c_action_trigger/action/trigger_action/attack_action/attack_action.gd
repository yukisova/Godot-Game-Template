class_name AttackAction
extends ITriggerAction

@export var hit_effects: Array[IHitEffect]

@export var binding_hitbox: HitboxMelee

@export var move_strategy: MoveStrategy

func _get_hit_effects() -> Array[IHitEffect]:
	return hit_effects

func _initialize():
	binding_hitbox.binding_action = self

func _trigger_update(...args):
	if binding_hitbox:
		binding_hitbox._release(move_strategy._get_current_direction())
	await get_tree().create_timer(1).timeout
	action_triggered_finished.emit(self)

func _trigger_update_finish():
	if binding_hitbox:
		binding_hitbox._reset()
