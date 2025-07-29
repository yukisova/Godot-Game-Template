##@editing:	Sora
##@describe:	背包系统扩展
extends StatusExtension

@export var inventory_array: Array[Item] ## 当前背包所包含的物品
@export var inventory_pack_num: int ## 背包的总容量
@export var inventory_weight_num: float ## 背包的总承重

var current_pack_num: int ## 当前背包的容量
var current_weight_num: float ## 当前的承重
