class_name CFSAttachPlayer
extends CameraFollowStrategy

var current_offset: Vector2 = Vector2.ZERO
var target_offset: Vector2 = Vector2.ZERO

func _init(_offset: Vector2 = Vector2.ZERO) -> void:
	current_offset = _offset
	target_offset = _offset

func _strategy(camera_viewport: CameraViewport, _delta: float) -> void:
	current_offset = current_offset.lerp(target_offset, _delta * 10)
	camera_viewport.camera.position = current_offset

## 渐变偏移，通过tween修改target_offset，让每一帧都会执行的_stategy将current_offset渐变到target_offset
func tween_offset(_target_offset: Vector2, _duration: float, tween: Tween):
	tween.tween_property(self, "target_offset", _target_offset, _duration)
	await tween.step_finished
	
