## 物品基类 - 游戏中所有物品的基础资源类型
##
## 该基类定义了游戏中物品的基本属性和行为。所有具体的物品类型
## （如武器、装备、消耗品等）都应该继承自此类。
##
## 基础属性：
## - 物品名称和描述信息
## - 视觉表示（纹理和网格大小）
## - 物理属性（重量）
## - 网格背包系统集成
##
## 功能特性：
## - 重量计算系统
## - 网格价值计算（用于自动整理）
## - 可扩展的物品行为系统
## - 物品操作接口（检查、使用等）
##
## 使用场景：
## - 背包系统的物品管理
## - 物品拖拽和交互
## - 物品重量和空间计算
## - 物品功能的动态调用
##
## 架构设计：
## - 继承自 [Resource] 基类
## - 基于 [Vector2i] 的网格尺寸系统
## - 提供 [Callable] 的动态功能接口
## - 与 [CStatus] 系统集成
##
## [br][b]注意:[/b] 文档（Document）类应该是独立的资源类，不应归属于物品
##
## [br][b]编辑者:[/b] Sora
class_name Item
extends Resource

## 物品昵称
## 
## 物品的简短名称或别名。
@export var item_nick_name: String

## 物品名称
## 
## 物品的正式名称。
@export var item_name: String

## 物品描述
## 
## 物品的详细描述信息，支持多行文本。
@export_multiline var item_description: String

## 物品纹理
## 
## 物品的视觉表示图像，类型为 [Texture2D]。
@export var item_texture: Texture2D

## 物品网格大小
## 
## 物品的Tile大小，每个Tile以80px为单位。类型为 [Vector2i]。
@export var item_tilesize: Vector2i = Vector2i(1,1)

## 物品重量
## 
## 物品重量，用于背包重量计算。
@export var item_weight: float = 1.0

## 获取物品重量
## 
## [br][br][b]返回:[/b] [float] 物品的重量值
func get_weight() -> float:
	return item_weight

## 获取物品网格价值
## 
## 用于自动整理时的排序，通常基于物品占用的网格数量。
## [br][br][b]返回:[/b] [int] 物品的网格价值（网格面积）
func get_grid_value() -> int:
	return item_tilesize.x * item_tilesize.y

## 检查物品
## 
## 物品的检查功能，显示物品相关信息。
## [param args]: 可变参数，第一个参数应为 [CStatus] 类型
func _check(...args):
	var c_status = args[0] as CStatus
	print("玩家的名字 ", c_status.component_owner.name)

## 使用物品
## 
## 物品的使用功能，执行物品的主要效果。
## [param args]: 可变参数，第一个参数应为 [CStatus] 类型
func _use(...args):
	var c_status = args[0] as CStatus
	
## 物品功能字典键名常量
const STR_NAME = "name"  ## 功能名称键
const STR_FUNC = "func"  ## 功能回调键
const STR_TEXT = "text"  ## 功能显示文本键

## 获取物品可调用功能列表
## 
## 返回物品支持的所有操作功能，用于动态生成物品右键菜单等。
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
