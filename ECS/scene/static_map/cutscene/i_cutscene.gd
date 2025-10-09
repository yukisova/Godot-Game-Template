## 过场剧情基类 - 定义过场剧情的抽象接口
## 该抽象类为所有过场剧情提供统一的框架和启动方法
@tool
@abstract class_name CutsceneNode
extends Node

signal cutscene_started(start_node: CutsceneNode)
signal cutscene_ended(start_node: CutsceneNode)

## 当前过场剧情节点为起始节点的时候，当过场剧情结束时会输出该信号
signal cutscene_output(output: Dictionary)

## 需要通过外部注入的信息，一般是配合InteractionCutscene使用
var cutscene_context: Dictionary

func _ready() -> void:
	cutscene_started.connect(_on_cutscene_started)
	cutscene_ended.connect(_on_cutscene_ended)

func _start() -> String:
	return "DEFAULT"

func _return() -> Dictionary:
	return {}

@export var branch_cutscenes: Dictionary[String, CutsceneNode]:
	set(v):
		if v.has(""):
			var info = v.get("")
			v.erase("")
			v["DEFAULT"]= info
		branch_cutscenes = v
	
func _on_cutscene_started(start_node: CutsceneNode = self) -> void:
	var current_state = SGameState.state_machine.get_leaf_state()
	if current_state is GamingStateNormal:
		current_state.game_cutscene_started.emit()
		await current_state.belong_state_machine.state_transition_finished
	elif current_state is not GamingStateCutscene:
		push_error("过场剧情只能在正常游戏状态或过场剧情状态中启动, 目前状态为: ", current_state)
		cutscene_ended.emit(start_node)
		return

	var branch_name = await _start()

	if branch_name == "":
		cutscene_ended.emit(start_node)
	else:
		if branch_name in branch_cutscenes.keys():
			branch_cutscenes[branch_name].cutscene_started.emit.call_deferred(start_node)
		else:
			cutscene_ended.emit(start_node)

func _on_cutscene_ended(start_node: CutsceneNode) -> void:
	start_node.cutscene_output.emit(await _return())
	var current_state = SGameState.state_machine.get_leaf_state()
	if current_state is GamingStateCutscene:    
		current_state.game_retryed.emit()
		await current_state.belong_state_machine.state_transition_finished
	else:
		push_error("过场剧情只能在过场剧情状态中结束， 目前状态为: ", current_state)

#region
const PATH_DIALOGUE_NORMAL: String = "res://ui/ui/ui_dialogue/normal/ui_dialogue_normal.tscn"

func start_dialogue(dialogue_resource: DialogueResource, label: String, info: Dictionary):
	var fixed_info = SoraEvent.fixed_dictionary(self, info)
	var float_dialogue: PackedScene = load(PATH_DIALOGUE_NORMAL)
	var dialogue_ui = await SUiSpawner._spawn_ui(float_dialogue, {}, true)
# 启动对话气泡，开始对话流程
	DialogueManager._start_balloon(dialogue_ui, dialogue_resource, label, [fixed_info])
	await DialogueManager.dialogue_ended

func start_caption(dialogue_resource: DialogueResource, label: String, info: Dictionary):
	var fixed_info = SoraEvent.fixed_dictionary(self, info)
	var dialogue_caption: UIHudController = SUiSpawner._get_hud("caption")
	dialogue_caption.caption_changed.emit(dialogue_resource, label)
	await dialogue_caption.caption_ended
	return
#endregion
