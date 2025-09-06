## 辅助用的节点数据基类，用于存储节点的一些数据，在编辑器中使用，不会在游戏中起作用
extends Node

@export var node_image: Dictionary[String, Texture2D]

func _ready() -> void:
    if !Engine.is_editor_hint():
        queue_free()