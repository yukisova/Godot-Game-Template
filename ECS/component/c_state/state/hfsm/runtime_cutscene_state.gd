@tool
class_name RuntimeCutsceneState
extends StateMachineAIO

func _setup() -> void:
	super()
	state_method_dict["cutscene_waiting"] = {
		"enter": Callable(_enter_of_cutscene_waiting),
		"update": Callable(_update_of_cutscene_waiting),
		"exit": Callable(_exit_of_cutscene_waiting)
	}
	state_method_dict["cutscene_running"] = {
		"enter": Callable(_enter_of_cutscene_running),
		"update": Callable(_update_of_cutscene_running),
		"exit": Callable(_exit_of_cutscene_running)
	}
	state_method_dict["cutscene_finished"] = {
		"enter": Callable(_enter_of_cutscene_finished),
		"update": Callable(_update_of_cutscene_finished),
		"exit": Callable(_exit_of_cutscene_finished)
	}
	state_method_dict["cutscene_pause"] = {
		"enter": Callable(_enter_of_cutscene_pause),
		"update": Callable(_update_of_cutscene_pause),
		"exit": Callable(_exit_of_cutscene_pause)
	}
	init_state_str = "cutscene_waiting"
	current_state_str = init_state_str
	

func _enter():
	state_method_dict[current_state_str].enter.call()

func _exit():
	state_method_dict[current_state_str].exit.call()


#region :等待过场启动:
func _enter_of_cutscene_waiting():
	pass

func _update_of_cutscene_waiting(_delta: float):
	pass

func _exit_of_cutscene_waiting():
	pass
#endregion

#region :过场逻辑:
func _enter_of_cutscene_running():
	pass
	
func _update_of_cutscene_running(_delta: float):
	pass
	
func _exit_of_cutscene_running():
	pass
#endregion

#region :过场结束逻辑:
func _enter_of_cutscene_finished():
	pass
func _update_of_cutscene_finished(_delta: float):
	pass
func _exit_of_cutscene_finished():
	pass
#endregion

#region :过场暂停逻辑:
func _enter_of_cutscene_pause():
	pass
func _update_of_cutscene_pause(_delta: float):
	pass
func _exit_of_cutscene_pause():
	pass
#endregion
