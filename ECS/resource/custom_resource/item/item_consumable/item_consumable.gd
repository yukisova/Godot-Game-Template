## 消耗品物品
## [br][b]编辑者:[/b] Sora
class_name ItemConsumable
extends Item

## 物品描述
## 物品的详细描述信息，支持多行文本
@export_multiline var item_description: String

## 物品纹理
## 物品的视觉表示图像，类型为 [Texture2D]
@export var item_texture: Texture2D

## 物品网格大小
## 物品的Tile大小，每个Tile以80px为单位
@export var item_tilesize: Vector2i = Vector2i(1,1)

## 物品重量
## 物品重量，用于背包重量计算
@export var item_weight: float = 1.0

## 获取物品重量
## [br][br][b]返回:[/b] [float] 物品的重量值
func get_weight() -> float:
	return item_weight

## 用于自动整理时的排序，通常基于物品占用的网格数量
## [br][br][b]返回:[/b] [int] 物品的网格价值（网格面积）
func get_grid_value() -> int:
	return item_tilesize.x * item_tilesize.y

## 物品的检查功能，显示物品相关信息
## [param args]: 可变参数，第一个参数应为 [CStatusList] 类型
func _check(...args):
	var c_status = args[0] as CStatusList
	print("玩家的名字 ", c_status.component_owner.name)

## 物品的使用功能，执行物品的主要效果
## [param args]: 可变参数，第一个参数应为 [CStatusList] 类型
func _use(..._args):
	# var c_status = _args[0] as CStatusList
	pass
	

## 返回物品支持的所有操作功能，用于动态生成物品右键菜单等
## [br][br][b]返回:[/b] [Array] 功能字典数组，每个字典包含name、func、text键
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
