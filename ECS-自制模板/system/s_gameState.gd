extends ISystem

signal gamedata_loaded

@export var state_machine: StateMachine
var is_setup = false

func _enter_tree() -> void:
	Main.s_game_state = self

func _setup():
	gamedata_loaded.connect(func():
		await state_machine.transition_finished
		var current_state = state_machine._get_leaf_state()
		if current_state is GameStartTransition:
			current_state.update_trigger = true
		else:
			printerr("WTF错误: gameloaded触发后按理来说一定是在GameStartTransition下")
		)
	state_machine._setup()
	state_machine._enter()
	is_setup = true
	
func _process(delta: float) -> void:
	if is_setup:
		#print("当前游戏状态为",state_machine._get_leaf_state().name)
		state_machine._update(delta)

func _physics_process(delta: float) -> void:
	if is_setup:
		state_machine._fixed_update(delta)
