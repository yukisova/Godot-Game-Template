## 可拖拽物品
class_name DragableItem
extends TextureRect

var binding_item: Item:
	set(v):
		binding_item = v
		texture = binding_item.item_texture

var origin_position := global_position

func _tween_selected():
	var tween = get_tree().create_tween()
	tween.tween_property(self,"scale", Vector2(0.7,0.7), 0.3)

func _tween_unselected():
	var tween = get_tree().create_tween()
	tween.tween_property(self,"scale", Vector2(1,1), 0.3)
