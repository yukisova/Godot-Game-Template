@tool
extends RuntimeCutsceneSM

@export var c_navigation: CNavigation
@export var movement_speed: int = 3000
@export var target_marker: Marker2D
@export var c_interactable: CInteractable

var true_toward: Vector2

var interaction_dialogue: Interaction

func _setup() -> void:
	super()
	c_navigation.nav_agent.velocity_computed.connect(func(safe_velocity):
		var character = c_navigation.component_body as CharacterBody2D
		if current_state_str == "cutscene_running":
			character.velocity = lerp(character.velocity, safe_velocity, 0.2)
		else:
			character.velocity = lerp(character.velocity, Vector2.ZERO, 0.2)
		character.move_and_slide()
	)
	await get_tree().create_timer(10).timeout
	interaction_dialogue = c_interactable.interaction_infos[0].interaction
	state_transition.emit("cutscene_running")

#region :等待过场启动:
func _enter_of_cutscene_waiting():
	c_navigation.component_owner.hide()
func _update_of_cutscene_waiting(_delta: float):
	pass
func _exit_of_cutscene_waiting():
	c_navigation.component_owner.show()
#endregion

#region :过场逻辑:
func _enter_of_cutscene_running():
	interaction_dialogue.test_dialogue_label = "ep0_地铁内_与健治初见"
	var nav_agent = c_navigation.nav_agent
	var target_position = target_marker.global_position
	nav_agent.target_position = target_position
	
	interaction_dialogue.interact_activated.connect(func(entity: FixedEntity):
		true_toward = c_interactable.component_body.global_position.direction_to(entity.global_position).normalized()
		state_transition.emit("cutscene_pause")
	)

func _update_of_cutscene_running(_delta: float):
	if c_navigation.nav_agent.is_navigation_finished():
		state_transition.emit("cutscene_finished")
		return

	var target_position: Vector2 = c_navigation.nav_agent.get_next_path_position()
	var target_direction: Vector2 = c_navigation.component_body.global_position.direction_to(target_position).normalized()
	var _owner_body = c_navigation.component_owner.main_control as CharacterBody2D
	var _velocity = target_direction * movement_speed * _delta

	if c_navigation.nav_agent.avoidance_enabled:
		c_navigation.nav_agent.velocity = _velocity
	else:
		_owner_body.velocity = _velocity
		_owner_body.move_and_slide()

func _exit_of_cutscene_running():
	c_interactable.interaction_infos[0].is_passive = false
	c_interactable.change_interaction_info_type(0, InteractionRecord.InteractType.RayCasted)

	interaction_dialogue.test_dialogue_label = "ep0_隐藏_提前与健治交流"
#endregion

#region :过场结束逻辑:
func _enter_of_cutscene_finished():
	pass
func _update_of_cutscene_finished(_delta: float):
	pass
func _exit_of_cutscene_finished():
	pass
#endregion

#region :过场暂停逻辑: 进入了对话状态
func _enter_of_cutscene_pause():
	await DialogueManager.dialogue_ended
	state_transition.emit("cutscene_running")
	
func _update_of_cutscene_pause(_delta: float):
	pass
func _exit_of_cutscene_pause():
	pass
#endregion
