## @describe: 物品融合系统
class_name SSItemFusion
extends SubSystem

## FIXME 合成的逻辑，但感觉更加适合放在物品内部，之后如果没啥大问题可以放在
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

#region :存档系统，将黑板的信息全部保存下来:
func _save_as(data: SavedDataFile):
	var result = {}
	return {
		keyword:result
	}

func _load_by(data: SavedDataFile):
	pass
#endregion
