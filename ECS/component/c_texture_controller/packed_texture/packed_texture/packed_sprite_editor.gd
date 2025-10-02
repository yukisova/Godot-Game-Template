class_name PackedSpriteEditor
extends Node

## 主精灵部件，IPackedSprite类型的主要精灵组件引用
@export var main_part: IPackedSprite
## 控制部件字典，存储角色各个部位的Node2D引用，常用键名：Body、Head、Left、Right
@export var control_parts: Dictionary[StringName, Node2D]
@export var animation_player: AnimationPlayer
## 拼接纹理的父节点，用于控制纹理的着色器与幅度并不大的位移
@export var texture_lib: MainSprite
var texture_switch_command: Dictionary[StringName, Callable]

func _initialize():
	_initialize_texture_switch_command()

func _update(_delta: float):
	pass

func _initialize_texture_switch_command():
	pass

func try_switch_texture(texture_name: StringName):
	if texture_switch_command.has(texture_name):
		texture_switch_command[texture_name].call()
	else:
		print("未发现对应的纹理切换命令")
