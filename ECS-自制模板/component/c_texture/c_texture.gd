##@editing:	Sora
##@describe:纹理组件,标明实体所使用的纹理
@tool
class_name C_Texture
extends IComponent

@export_subgroup("信息")
@export_node_path("AnimatedSprite2D","Sprite2D","PackedSprite") var texture_path: NodePath
@export var animation_player: AnimationPlayer ## 可选的动画器
@export var animation_tree: AnimationTree ## 可选的动画状态机

@export var sprite_change_list: Dictionary[String, Texture2D]

func _enter_tree() -> void:
	component_name = ComponentName.c_texture

func _initialize(_owner: Entity):
	super(_owner)

func _get_texture():
	
	return get_node(texture_path)
