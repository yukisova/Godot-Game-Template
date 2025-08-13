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

## 获取物品网格价值
## 用于自动整理时的排序，通常基于物品占用的网格数量
## @return: 物品的网格价值（网格面积）
func get_grid_value() -> int:
	return item_tilesize.x * item_tilesize.y

func _check(...args):
	var c_status = args[0] as C_Status
	print("玩家的名字 ", c_status.component_owner.name)
	
func _use(...args):
	var c_status = args[0] as C_Status
	
const STR_NAME = "name"
const STR_FUNC = "func"
const STR_TEXT = "text"

func get_func_callable() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	result.push_front({
		STR_NAME:"check",
		STR_FUNC:_check,
		STR_TEXT:"调查"
	})
	result.push_front({
		STR_NAME:"use",
		STR_FUNC:_use,
		STR_TEXT:"使用"
	})
	return result
