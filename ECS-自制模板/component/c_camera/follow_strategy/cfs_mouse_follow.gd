##@editing:	Sora
##@describe:	类孤胆枪手-根据鼠标的位置对镜头进行偏移
extends CameraFollowStrategy

@export_range(0.0, 1.0, 0.01) var smoothing: float = 0.1

const STATIC_ZONE = 20.0
func _strategy(_delta: float) -> void:
		
	var mouse_offset = c_camera.component_body.get_local_mouse_position()
	# 计算归一化偏移向量
	
	# 当鼠标在中心区域时不移动相机
	if mouse_offset.length() < STATIC_ZONE:
		c_camera.camera.position = Vector2.ZERO
		return
	
	# 计算实际相机偏移量
	var actual_offset = mouse_offset.normalized() * (mouse_offset.length() - STATIC_ZONE) * 0.32
	# 应用平滑过渡
	c_camera.camera.position = c_camera.camera.position.lerp(actual_offset, min(smoothing * 60 * _delta, 1.0))
