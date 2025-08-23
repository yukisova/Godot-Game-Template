## 游戏主摄像头控制器 - 管理游戏主摄像头的移动和缩放
## 负责跟随玩家角色移动并提供缩放功能，支持单人和双人游戏模式
## 使用ViewportManager实现动态视口分割和大小调整
## [br][b]编辑者:[/b] Sora
extends ISystem


## 当前的主摄像头
var current_camera: Camera2D

@export var camera_viewport_scene: PackedScene

@export_group("依赖")
@export var game_viewport_grid: GridContainer

var camera_viewports: Array[CameraViewport] = []
## 视口管理器
@export var viewport_manager: ViewportManager
## 会等待玩家节点设置之后才会正式开始
func _setup():
	# 初始化视口管理器（如果没有在编辑器中设置）
	if not viewport_manager:
		viewport_manager = ViewportManager.new()
		add_child(viewport_manager)
	
	# 初始化视口管理器的容器
	viewport_manager.initialize(game_viewport_grid)
	
	## 完成游戏数据加载之后，会正式开始
	SSignalBus.game_loop_start.connect(_setup_viewports_for_play_type)

## 根据游戏模式设置视口
func _setup_viewports_for_play_type():
	match SMainController.play_type:
		SMainController.PlayType.SINGLE:
			_setup_single_player_viewport()
		SMainController.PlayType.DOUBLE:
			_setup_double_player_viewport()

## 设置单人模式视口
func _setup_single_player_viewport():
	if not viewport_manager:
		push_error("ViewportManager 未初始化")
		return
		
	viewport_manager.set_layout(ViewportManager.LayoutType.SINGLE)
	
	var camera_viewport: CameraViewport = camera_viewport_scene.instantiate()
	camera_viewports.append(camera_viewport)
	camera_viewport.camera_target = SMainController.player_static.main_control
	camera_viewport.viewport.world_2d = SMapData.current_level.get_parent().world_2d
	
	viewport_manager.add_viewport(camera_viewport)
	current_camera = camera_viewport.camera


## 设置双人模式视口
func _setup_double_player_viewport():
	if not viewport_manager:
		push_error("ViewportManager 未初始化")
		return
		
	# 默认使用水平分割，可以根据需要调整为垂直分割
	viewport_manager.set_layout(ViewportManager.LayoutType.DOUBLE_H)
	
	# 玩家1视口
	var camera_viewport1: CameraViewport = camera_viewport_scene.instantiate()
	camera_viewports.append(camera_viewport1)
	camera_viewport1.camera_target = SMainController.player_static.main_control
	camera_viewport1.viewport.world_2d = SMapData.current_level.get_parent().world_2d
	viewport_manager.add_viewport(camera_viewport1)
	
	# 玩家2视口（如果有第二个玩家）
	var camera_viewport2: CameraViewport = camera_viewport_scene.instantiate()
	camera_viewports.append(camera_viewport2)
	camera_viewport2.camera_target = SMainController.player_static_2.main_control  # 暂时使用同一个玩家
	camera_viewport2.viewport.world_2d = SMapData.current_level.get_parent().world_2d
	viewport_manager.add_viewport(camera_viewport2)
	
	current_camera = camera_viewport1.camera

## 动态切换视口布局（可在运行时调用）
## [param layout]: 新的布局类型
func switch_viewport_layout(layout: ViewportManager.LayoutType):
	if viewport_manager:
		viewport_manager.switch_layout(layout, true)  # 使用平滑过渡

## 获取当前视口信息（用于调试）
func get_viewport_info() -> Dictionary:
	if viewport_manager:
		return viewport_manager.get_layout_info()
	return {}

func _resetup():
	# 清理现有视口
	if viewport_manager:
		viewport_manager.clear_all_viewports()
		camera_viewports.clear()
	# 重新设置
	_setup_viewports_for_play_type()
