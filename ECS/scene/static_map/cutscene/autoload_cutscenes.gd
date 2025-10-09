## 在StaticMap场景中集合的Cutscene特殊脚本
@tool
class_name AutoLoadCutscenes
extends Node

var cutscenes: Array[CutsceneNode]

func _ready() -> void:
	for i in get_children():
		if i is CutsceneNode:
			cutscenes.append(i)
			if cutscenes.size() > 1:
				i.branch_cutscenes[""] = cutscenes[cutscenes.size() - 2]
	
func _initialize() -> void: 
	#await SMapData.current_level.level_component_initialized
	#await get_tree().process_frame
	if cutscenes.is_empty(): return
	cutscenes[0].cutscene_started.emit()
	
