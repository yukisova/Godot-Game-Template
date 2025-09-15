## 打包精灵接口 - 提供高级纹理管理和动态动画切换功能
## 支持多纹理动态切换、状态驱动的纹理切换系统
## 用于角色换装、武器外观切换、环境纹理变化等场景
## [br][b]编辑者:[/b] Sora
class_name IPackedSprite
extends Node2D

var texture_toward: Vector2 = Vector2.RIGHT:
	set(value):
		texture_toward = value
		packed_sprite_editor.rotation_angle = value.angle() / -2 / PI
		
@export var packed_sprite_editor: PackedSpriteEditor
@export var shadow: Sprite2D ## 地面阴影，根据它来判断纹理与地面的距离
@export var height_top_marker: Marker2D ## 高度标记1，根据它来判断角色的高度
@export var height_bottom_marker: Marker2D ## 高度标记2，根据它来判断角色的高度

var c_texture_controller: CTextureController


func _initialize():
	packed_sprite_editor._initialize()

func _update(_delta: float) -> void:
	packed_sprite_editor._update(_delta)

## 尝试播放动画
func try_animation(_animation_name: String) -> bool:
	return false

func _reset():
	pass
