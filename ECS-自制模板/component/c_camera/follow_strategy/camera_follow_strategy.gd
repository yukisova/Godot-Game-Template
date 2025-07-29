##@editing:	Sora
##@describe:	镜头跟随策略基类, 感觉有些冗余
@abstract class_name CameraFollowStrategy
extends Node

var c_camera: C_Camera

@abstract func _strategy(_delta: float) -> void
