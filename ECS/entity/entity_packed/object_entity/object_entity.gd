## 对象实体
## 用于表示一些不会
## 通常是静态的，不会移动，但可以被其他实体碰撞
## 通常用于表示游戏中的一类物品、建筑物、地形等，因为这类实体的用处单一但复杂，于是单独封装
## 如：传送门 -> 传送门的碰撞体可能各有不同, 但功能固定，要指定目标地点，所以单独封装
@tool
@abstract class_name ObjectEntity
extends IEntity


## 实体原生存在标志
## 标识实体是否为静态地图中的原生对象（vs 动态创建的对象）
var is_entity_origin_exist: bool

func _setup() -> void:
    pass

func _update(_delta: float) -> void:
    pass

func _fixed_update(_delta: float) -> void:
    pass

func _initialize() -> void:
    pass
