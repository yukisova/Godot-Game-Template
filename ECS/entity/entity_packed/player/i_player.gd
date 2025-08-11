## 玩家的实体，为了与其他实体区分开来，正确保存在s_main_control当中
@tool
extends IEntity

func _save_as() -> Dictionary:
    return {}
func _load_by(data: Dictionary):
    pass