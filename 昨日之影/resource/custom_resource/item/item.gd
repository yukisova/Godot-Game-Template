## @editing: Sora [br]
## @describe: 物品的基类
class_name Item
extends Resource

@export var item_nick_name: String
@export var item_name: String
@export_multiline var item_description: String
@export var item_texture: Texture2D
var item_tilesize: Vector2i = Vector2i(1,1) ## 物品的Tile大小，

func _check():
	pass
func _use():
	pass
