@abstract class_name Item
extends Resource

var item_name: String
var item_description: String
var item_texture: Texture2D
var item_tilesize: Vector2i = Vector2i(1,1) ## 物品的Tile大小，

@abstract func _check()
@abstract func _use()
