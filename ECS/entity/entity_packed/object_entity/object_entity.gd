## 对象实体类 - ECS架构中的静态对象实体
## 用于表示游戏中的特点鲜明的且常用的实体，例如传送门、物品收集点、剧情触发区域、机关装置、建筑物等环境交互元素
## [br][b]编辑者:[/b] Sora
@tool
@abstract class_name ObjectEntity
extends IEntity

## 实体原生存在标志，与fixed_entity中同名变量作用一致
var is_entity_origin_exist: bool

func _setup() -> void:
	pass

func _update(_delta: float) -> void:
	pass

func _fixed_update(_delta: float) -> void:
	pass

func _initialize() -> void:
	pass
