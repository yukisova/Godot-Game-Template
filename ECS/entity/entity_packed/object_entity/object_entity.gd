## 对象实体类 - ECS架构中的静态对象实体
##
## 用于表示游戏中静态但可交互的对象，通常是不移动的环境元素。
## 这类实体功能相对单一但实现复杂，因此单独封装以便复用。
##
## 典型应用场景：
## - 传送门：碰撞体各异，但功能固定（传送到指定地点）
## - 物品收集点：外观不同，但都提供物品获取功能
## - 机关装置：形状多样，但都有特定的触发逻辑
## - 建筑物：结构复杂，提供特定的交互功能
##
## 架构特点：
## - 静态存在，不主动移动
## - 可被其他实体碰撞和交互
## - 功能专一但实现复杂
## - 适合作为环境交互元素
##
## 继承设计：
## - 继承自 [IEntity] 基类
## - 抽象类，需要具体实现子类
## - 提供统一的对象实体接口
##
## [br][b]编辑者:[/b] Sora
@tool
@abstract class_name ObjectEntity
extends IEntity


## 实体原生存在标志
## 
## 标识实体是否为静态地图中的原生对象（vs 动态创建的对象）。
var is_entity_origin_exist: bool

func _setup() -> void:
    pass

func _update(_delta: float) -> void:
    pass

func _fixed_update(_delta: float) -> void:
    pass

func _initialize() -> void:
    pass
