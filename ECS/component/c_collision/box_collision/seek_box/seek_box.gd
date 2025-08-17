## 搜索检测盒 - 与交互盒对接的检测碰撞体
##
## 该类用于实体的主动搜索和交互目标检测。当搜索检测盒与交互盒发生碰撞时，
## 会将交互对象添加到搜索目标列表中，用于AI寻找和选择交互目标。
##
## 搜索特性：
## - 目标收集：自动收集范围内的交互对象
## - 与交互系统对接：专门与 [InteractionBox] 配合使用
## - 动态目标管理：实时更新搜索到的目标列表
##
## 应用场景：
## - AI搜索：NPC寻找可交互的对象
## - 目标选择：自动选择最近的交互目标
## - 范围检测：检测范围内的所有可交互物体
##
## 架构设计：
## - 继承自 [BoxCollision] 基类
## - 基于 [enum CCollision.BoxCollisionName.SEEK] 类型
## - 存储 [Array] of [Interaction] 目标列表
##
## [br][b]编辑者:[/b] Sora
class_name SeekBox
extends BoxCollision

## 搜索目标列表
## 
## 存储当前检测范围内的所有交互目标，类型为 [Array] of [Interaction]。
var seek_target : Array[Interaction] = []

func _enter_tree() -> void:
	box_collision_name = CCollision.BoxCollisionName.SEEK