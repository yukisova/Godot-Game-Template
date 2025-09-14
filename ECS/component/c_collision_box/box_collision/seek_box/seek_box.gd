## 搜索检测盒 - 主动搜索和交互目标检测
## 收集范围内的交互对象，用于AI寻找和选择目标
## 存储搜索到的交互目标列表
## [br][b]编辑者:[/b] Sora
@tool
class_name SeekBox
extends BoxCollision

## 搜索目标列表
## 存储当前检测范围内的交互目标
var seek_target : Array[Interaction] = []

func _enter_tree() -> void:
	box_collision_name = CCollisionBox.BoxCollisionName.SEEK

func _initialize():
	pass