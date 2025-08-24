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

func _initialize():
	packed_sprite_editor._initialize()

func _update(_delta: float) -> void:
	packed_sprite_editor._update(_delta)

## 尝试播放动画
func try_animation(animation_name: String) -> bool:
	return false
