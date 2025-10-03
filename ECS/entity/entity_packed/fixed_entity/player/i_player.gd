@tool
extends FixedEntity

func _save_as(data: SavedDataFile) -> Dictionary:
	return {}
	

func _load_by(data: SavedDataFile) -> Dictionary:
	return {}

func _despawn():
	print("玩家死亡，弹出游戏结束")
	SSignalBus.game_overed.emit(1)

	
