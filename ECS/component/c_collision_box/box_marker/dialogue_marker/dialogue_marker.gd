## 对话框标记器
## 
## 用于标记对话框的标记器，类型为 [BoxMarker]。
## 主要用于对话框的显示和隐藏。
## [br][b]编辑者:[/b] Sora
@tool
extends BoxMarker

## 目标
@export var entity_portrait: Dictionary[String, Texture2D] 

@export var character_name: String
@export var balloon_color: Color = Color.WHITE
@export var text_color: Color = Color.BLACK

func _ready() -> void:
    add_to_group("dialogue_marker")

func _update(_delta: float) -> void:
    pass