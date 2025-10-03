class_name CFSAttachPlayer
extends CameraFollowStrategy

var offset: Vector2 = Vector2.ZERO

func _init(_offset: Vector2 = Vector2.ZERO) -> void:
	offset = _offset

func _strategy(camera_viewport: CameraViewport, _delta: float) -> void:
	camera_viewport.camera.position = offset
