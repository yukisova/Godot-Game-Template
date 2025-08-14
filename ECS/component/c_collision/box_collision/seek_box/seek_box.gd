## @editing: Sora [br]
## @describe: 与InteractionBox进行对接的boxCollsion
class_name SeekBox
extends BoxCollision

var seek_target : Array[Interaction] = []

func _enter_tree() -> void:
	box_collision_name = CCollision.BoxCollisionName.SEEK