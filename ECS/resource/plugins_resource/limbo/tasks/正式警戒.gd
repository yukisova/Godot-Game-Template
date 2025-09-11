@tool
extends BTAction

func _generate_name() -> String:
	return "正式进入警戒状态"

func _enter() -> void:
	print("敌人正式进入警戒状态")
	pass

func _tick(delta: float) -> Status:
	return Status.RUNNING
