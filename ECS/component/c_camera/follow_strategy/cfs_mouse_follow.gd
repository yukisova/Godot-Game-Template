## 鼠标跟随相机策略 - 根据鼠标位置进行相机偏移
## 该策略实现了类似于《孤胆枪手》等游戏的相机系统，相机会根据鼠标位置进行适当的偏移，让玩家能够看到鼠标指向的方向更多的内容。
## 策略特性：鼠标位置感应、静态区域设定（避免微小抖动）、平滑过渡效果、可配置的响应速度
## 适用场景：射击游戏、探索游戏、需要精确瞄准的游戏、动作冒险游戏
## [br][b]编辑者:[/b] Sora
class_name CameraFollowMouseStrategy
extends CameraFollowStrategy

## 平滑度参数
## 控制相机移动的平滑程度，值越小移动越平滑但响应越慢
@export_range(0.0, 1.0, 0.01) var smoothing: float = 0.1

## 静态区域半径
## 鼠标在此区域内时相机不会移动，避免微小的鼠标移动造成相机抖动
const STATIC_ZONE = 20.0

## 执行鼠标跟随策略，根据鼠标相对于实体的位置计算相机偏移，并应用平滑过渡
## [param _delta]: 帧时间间隔
func _strategy(_delta: float) -> void:
	# 获取鼠标相对于实体的本地位置
	var mouse_offset = c_camera.component_body.get_local_mouse_position()
	
	# 当鼠标在静态区域内时，相机回到中心位置
	if mouse_offset.length() < STATIC_ZONE:
		c_camera.camera_source.position = c_camera.camera_source.position.lerp(
			Vector2.ZERO, 
			min(smoothing * 60 * _delta, 1.0)
		)
		return
	
	# 计算超出静态区域的实际偏移量
	# 使用归一化方向 * (超出距离) * 偏移系数
	var excess_distance = mouse_offset.length() - STATIC_ZONE
	var actual_offset = mouse_offset.normalized() * excess_distance * 0.32
	
	# 应用平滑过渡到目标偏移位置
	c_camera.camera_source.position = c_camera.camera_source.position.lerp(
		actual_offset, 
		min(smoothing * 60 * _delta, 1.0)
	)
