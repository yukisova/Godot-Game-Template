class_name PackedSpriteEditor
extends Node

## 主精灵部件，IPackedSprite类型的主要精灵组件引用
@export var main_part: IPackedSprite
## 控制部件字典，存储角色各个部位的Node2D引用，常用键名：Body、Head、Left、Right
@export var control_parts: Dictionary[StringName, Node2D]
@export var animation_player: AnimationPlayer

func _initialize():
	pass

func _update(_delta: float):
	pass
