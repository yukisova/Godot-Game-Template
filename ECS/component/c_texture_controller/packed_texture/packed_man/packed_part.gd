
@tool
class_name PackedPart
extends Node2D

## [b]打包纹理部件类[/b]
##
## 用于管理角色身体各个部位的纹理组件。[br]
## 支持编辑器实时预览和运行时动态纹理管理。
##
## [b]主要功能:[/b]
## [color=green]•[/color] 自动创建和管理[color=blue]Sprite2D[/color]节点[br]
## [color=green]•[/color] 编辑器中的[b]实时纹理预览[/b][br]
## [color=green]•[/color] 运行时[b]纹理动态切换[/b][br]
## [color=green]•[/color] 纹理资源的[b]延迟加载[/b]
##
## [b]设计特点:[/b]
## [color=yellow]•[/color] [b]轻量级[/b]的纹理容器[br]
## [color=yellow]•[/color] 支持[color=orange]编辑器工具模式[/color][br]
## [color=yellow]•[/color] 自动处理[color=blue]节点生命周期[/color][br]
## [color=yellow]•[/color] 兼容[color=purple]打包精灵系统[/color]
##
## [b]使用场景:[/b]
## [color=red]•[/color] 角色身体部位（头部、身体、手臂等）[br]
## [color=red]•[/color] 装备外观切换[br]
## [color=red]•[/color] 动态纹理组合
##
## [br][b]编辑者:[/b] [color=purple]Sora[/color]

## [b]默认纹理资源[/b]
## 
## 部件的默认纹理，设置时会自动更新Sprite2D的纹理显示。[br]
## 在[color=orange]编辑器模式[/color]下支持实时预览，[color=green]运行时[/color]支持动态切换。
@export var default_texture: Texture2D:
	set(value):
		if value == null:
			return
		default_texture = value
		# 编辑器模式下立即更新纹理显示
		if Engine.is_editor_hint():
			if sprite == null:
				sprite = Sprite2D.new()
				add_child(sprite)
			sprite.texture = default_texture
@export var is_flip: bool:
	set(value):
		is_flip = value
		if sprite is Sprite2D:
			sprite.flip_h = is_flip

@export_range(1,2) var hframes: int:
	set(value):
		hframes = value
		if sprite is Sprite2D:
			sprite.hframes = value

## [b]内部Sprite2D节点[/b]
## 
## 实际显示纹理的[color=blue]Sprite2D[/color]节点，由本类自动创建和管理。[br]
## [color=red]无需手动操作[/color]，纹理更新通过[code]default_texture[/code]属性进行。
var sprite: Node2D:
	set(value):
		if value == null:
			return
		if sprite != null:
			sprite.queue_free()
		sprite = value

## [b]初始化方法[/b]
## 
## 在[color=green]运行时模式[/color]下初始化Sprite2D节点并设置默认纹理。[br]
## [color=orange]编辑器模式[/color]下跳过初始化，避免与编辑器预览冲突。
func _ready() -> void:
	# 编辑器模式下跳过初始化
	if Engine.is_editor_hint(): 
		return

	# 运行时模式下创建精灵节点并设置纹理
	if default_texture != null:
		if sprite == null:
			sprite = Sprite2D.new()
			add_child(sprite)
		sprite.texture = default_texture
