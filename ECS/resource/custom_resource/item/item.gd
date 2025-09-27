## 物品基类 - 游戏中所有物品的基础资源类型
## 该基类定义了游戏中物品的基本属性和行为，所有具体的物品类型都应该继承自此类
## 基础属性：物品名称和描述信息、视觉表示、物理属性、网格背包系统集成
## 功能特性：重量计算系统、网格价值计算、可扩展的物品行为系统、物品操作接口
## 使用场景：背包系统的物品管理、物品拖拽和交互、物品重量和空间计算
## 架构设计：继承自 [Resource] 基类，基于 [Vector2i] 的网格尺寸系统
## [br][b]注意:[/b] 文档（Document）类应该是独立的资源类，不应归属于物品
## [br][b]编辑者:[/b] Sora
class_name Item
extends Resource

## 物品昵称
## 物品的简短名称或别名
@export var item_nick_name: String

## 物品名称
## 物品的正式名称
@export var item_name: String

## 物品功能字典键名常量
const STR_NAME = "name"  ## 功能名称键
const STR_FUNC = "func"  ## 功能回调键
const STR_TEXT = "text"  ## 功能显示文本键