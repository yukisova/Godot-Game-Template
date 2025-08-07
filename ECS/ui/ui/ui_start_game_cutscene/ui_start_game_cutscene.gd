## 开始游戏的时候，进行的过场Ui(设置游戏的基础难度，设置游戏的使用角色并决定之后的剧情线)
extends IUi

@export var start_game_scene: PackedScene

@onready var animation_player: AnimationPlayer = $Control/AnimationPlayer
const dialog_panel_pack = preload("res://ui/ui_composite/canvas/dialogue_panel/dialog_panel.tscn")
const dialog_resource = preload("res://resource/plugins_resource/dialogue/ui_cutscene.dialogue")
const dialog_label = "ui_进入游戏"

func _ready() -> void:
	animation_player.play("tip")
	
	await animation_player.animation_finished
	
	var dialog_panel = dialog_panel_pack.instantiate()
	add_child(dialog_panel)
	DialogueManager._start_balloon(dialog_panel, dialog_resource, dialog_label, [])
	
	await DialogueManager.dialogue_ended
	
	var game_state_machine = SGameState.state_machine as StateMachineHfsm 
	
	var current_state = game_state_machine._get_active_state()
	if current_state is GameStartState:
		current_state.update_trigger = true
		SMapData.map_info_registered.emit(start_game_scene)
		SAudioMaster.play_music(null)
		unspawn()
	else:
		push_error("当前出现问题: 主菜单场景状态机错误！当前状态名:%s"%[current_state.name])
