# 贴图资源库
class_name MainSprite
extends Node2D

@export var lib: Array[SpriteLibRecord]

func find(node: Node, texture_name: StringName) -> Texture2D:
	var node_records = lib.filter(func(record: SpriteLibRecord) -> bool: return get_node(record.belong_node) == node)
	var target_index = node_records.find_custom(func(record: SpriteLibRecord) -> bool: return record.texture_name == texture_name)
	if target_index == -1:
		return null
	return node_records[target_index].texture
