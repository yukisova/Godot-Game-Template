## 交互碰撞盒 - 处理实体间交互检测
## 基于区域检测的交互系统，触发自动交互或交互提示
## 用于自动门、提示区域、收集物品等交互功能
## [br][b]编辑者:[/b] Sora
@tool
class_name InteractBox
extends BoxCollision

func _enter_tree() -> void:
	box_collision_name = CCollisionBox.BoxCollisionName.INTERACT
	collision_layer = Main.PhysicsLayer.Interactable

func _initialize():
	pass
