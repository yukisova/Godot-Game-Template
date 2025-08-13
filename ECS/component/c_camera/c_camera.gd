## @editing: Sora [br]
## @describe: 相机组件 - 为实体提供相机控制和跟随功能
## 
## 该组件实现了实体相关的相机控制系统，支持多种跟随策略和相机行为。
## 主要用于玩家角色的相机跟随，也可用于特殊的相机控制场景。
## 
## 跟随策略类型：
## - 平滑跟随：带有缓动的相机跟随
## - 直接跟随：即时响应的相机跟随
## - 预测跟随：根据移动方向预测位置的跟随
## - 鼠标辅助跟随：结合鼠标位置的混合跟随
## 
## 功能特性：
## - 策略模式的相机控制
## - 相机边界限制
## - 与地图系统集成
## - 平滑相机过渡
## - 可配置的跟随参数
@tool
class_name C_Camera
extends IComponent

@export_group("镜头控制策略","camera")
## 相机跟随策略
## 定义相机如何跟随实体的具体算法和行为
@export var camera_strategy: CameraFollowStrategy

## 相机源节点
## 实际执行相机功能的Camera2D节点
@export var camera_source: Camera2D

func _enter_tree() -> void:
	component_name = ComponentName.c_camera

## 组件初始化
## 设置相机策略绑定和相机边界限制
## @param _owner: 拥有此组件的实体
func _initialize(_owner: IEntity):
	super._initialize(_owner)
	
	# 绑定相机策略到组件
	camera_strategy.c_camera = self
	
	# 设置当前关卡的相机边界
	if SMapData.current_level:
		set_camera_limit(SMapData.current_level.get_camera_limit())
	else:
		push_warning("相机组件: 当前关卡数据不存在，无法设置相机边界")

## 设置相机边界限制
## 根据关卡数据设置相机的移动边界
## @param limit_dict: 包含边界信息的字典
func set_camera_limit(limit_dict: Dictionary):
	if camera_source:
		camera_source.limit_top = limit_dict.get("camera_top", -10000000)
		camera_source.limit_bottom = limit_dict.get("camera_bottom", 10000000)
		camera_source.limit_left = limit_dict.get("camera_left", -10000000)
		camera_source.limit_right = limit_dict.get("camera_right", 10000000)

## 相机更新
## 每帧调用相机策略的更新方法
## @param _delta: 帧时间间隔
func _update(_delta: float):
	if camera_strategy:
		camera_strategy._strategy(_delta)

## 获取相机位置
## @return: 相机在世界坐标系中的位置
func get_camera_position() -> Vector2:
	if camera_source:
		return camera_source.global_position
	return Vector2.ZERO

## 设置相机位置
## @param new_position: 新的相机位置
func set_camera_position(new_position: Vector2):
	if camera_source:
		camera_source.global_position = new_position

## 启用相机
## 将此相机设置为当前活跃的相机
func enable_camera():
	if camera_source:
		camera_source.enabled = true

## 禁用相机
## 禁用此相机
func disable_camera():
	if camera_source:
		camera_source.enabled = false
