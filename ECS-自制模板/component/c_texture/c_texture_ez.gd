## @deprecated: 已弃用

## @editing: Sora
## @describe: 更简单的纹理(基于AnimatedSprite) 
@tool
class_name C_TextureEz
extends IComponent

@export_subgroup("依赖")
@export var base_sprite: AnimatedSprite2D

@export_subgroup("信息")

func _enter_tree() -> void:
	component_name = ComponentName.c_texture

func _initialize(_owner: Entity):
	super(_owner)
