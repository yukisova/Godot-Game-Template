class_name SSItemFusion
extends SubSystem

@export var fusion_records: Array[FusionRecord]

func _enter_tree() -> void:
	keyword = &"item_fusion"

func _update(_delta: float):
	pass

func fusion_up(pre: String, pro: String) -> Item:
	for record in fusion_records:
		if record.material_pre == pre and record.material_pro == pro or record.material_pre == pro and record.material_pro == pre:
			return record.fusion_result.duplicate()
	return null
	
