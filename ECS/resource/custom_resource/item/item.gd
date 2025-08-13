## @editing: Sora [br]
## @describe: 物品的基类，文档并不属于应该属于物品，而是另外设定一个资源类
class_name Item
extends Resource

@export var item_nick_name: String
@export var item_name: String
@export_multiline var item_description: String
@export var item_texture: Texture2D
@export var item_tilesize: Vector2i = Vector2i(1,1) ## 物品的Tile大小，每个Tile拟以80px为单位
@export var item_weight: float = 1.0 ## 物品重量，用于背包重量计算

## 获取物品重量
## @return: 物品的重量值
func get_weight() -> float:
	return item_weight

func _check():
	pass
func _use():
	pass
