## 战争迷雾系统 - 动态视野遮罩和探索系统
## 该系统实现了类似RTS游戏的战争迷雾效果，提供基于玩家位置的动态视野管理
## 通过实时图像处理技术，创建沉浸式的探索体验
## 核心功能：基于玩家位置的动态视野揭示、实时图像处理和纹理更新、性能优化的移动检测机制
## 技术特性：实时图像混合算法、优化的重绘触发机制、可扩展的光源系统、内存高效的纹理管理
## 应用场景：探索类游戏的视野限制、地牢和迷宫的逐步揭示、战略游戏的战争迷雾
## 架构设计：继承自 [Sprite2D] 基类，集成 [SMainController] 的玩家管理
## [br][b]编辑者:[/b] Sora
class_name Fog
extends TextureRect

#region 迷雾配置

## 相机限制区域，用于确定迷雾的范围
@export var camera_limit: Control

## 光照纹理
## 用于揭示迷雾的光源纹理资源，类型为 [Texture2D]
@export var light_texture: Texture2D

#endregion

#region 迷雾数据

## 迷雾图像数据
## 存储当前迷雾状态的像素数据，类型为 [Image]
var fog_image: Image

## 迷雾纹理对象
## 用于显示的动态纹理，类型为 [ImageTexture]
var fog_texture: ImageTexture

## 光照图像数据
## 光源纹理的像素数据缓存，类型为 [Image]
var light_image: Image

## 当前图像
## 用于存储当前的图像数据，类型为 [Image]
var current_image: Image

## 当前纹理对象
## 用于显示的动态纹理，类型为 [ImageTexture]
var current_texture: ImageTexture

#endregion

#region 玩家引用


#endregion

## 禁用处理模式，等待初始化完成
func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

## 初始化迷雾系统的所有组件和纹理数据
func _initialize():
	# 验证必需的组件
	if not _validate_components():
		push_error("迷雾系统: 初始化失败，缺少必需的组件")
		return

	## 创建迷雾的图像数据
	var fog_size = Vector2i(int(camera_limit.size.x), int(camera_limit.size.y))
	if fog_size.x <= 0 or fog_size.y <= 0:
		push_error("迷雾系统: 无效的相机限制尺寸 %s" % fog_size)
		return
	
	fog_image = Image.create(fog_size.x, fog_size.y, false, Image.FORMAT_RGBA8)
	# 填充白色作为底色, 在着色器中，会将白色进行一定的偏转，使其可以被识别为未探索区域
	fog_image.fill(Color.WHITE)
	# 创建迷雾的纹理对象
	fog_texture = ImageTexture.create_from_image(fog_image)
	# 设置纹理对象
	texture = fog_texture

	current_image = fog_image.duplicate()
	current_texture = fog_texture.duplicate()

	# 验证材质存在
	if material and material.has_method("set_shader_parameter"):
		material.set_shader_parameter("current_texture", current_texture)
	else:
		push_error("迷雾系统: 材质或着色器参数设置失败")
		return
	
	## 获取光源的图像数据
	if light_texture:
		light_image = light_texture.get_image()
	else:
		push_error("迷雾系统: 光源纹理未设置")
		return
	
	update_fog()
	process_mode = Node.PROCESS_MODE_INHERIT
	print("迷雾系统: 初始化完成，尺寸: %s" % fog_size)
	
## 检测玩家移动并触发迷雾更新
## [param _delta]: 帧时间间隔，类型为 [float]
func _process(_delta: float) -> void:
	# 安全检查：确保玩家引用存在
	var player = SMainController._get_player_info_by_index(0)
	if player and not player.main_control.velocity.is_equal_approx(Vector2.ZERO):
		update_fog()

## 基于玩家当前位置更新迷雾的揭示区域
func update_fog():
	var entity = SMainController._get_player_info_by_index(0)
	# 安全检查：确保所有必需的对象都存在
	if not entity or not fog_image or not light_image:
		return
	
	var player = entity.main_control
	
	# 获取玩家在世界坐标系中的位置
	var player_world_pos = player.global_position
	
	# 获取迷雾系统的世界坐标起始位置（camera_limit的左上角）
	var fog_world_origin = camera_limit.global_position
	
	# 将玩家的世界坐标转换为迷雾图像的本地坐标
	var player_local_pos = player_world_pos - fog_world_origin + Vector2(0, -20)
	
	# 计算光源在迷雾图像中的位置（以光源中心对齐玩家位置）
	var light_size = light_image.get_size()
	var light_position = player_local_pos - Vector2(light_size.x / 2, light_size.y / 2)
	
	# 确保光源位置在迷雾图像范围内（边界检测）
	var fog_size = fog_image.get_size()
	light_position.x = clamp(light_position.x, 0, fog_size.x - light_size.x)
	light_position.y = clamp(light_position.y, 0, fog_size.y - light_size.y)
	
	# 将光源图像与迷雾图像进行混合，揭示玩家周围区域
	fog_image.blend_rect(light_image, Rect2i(Vector2.ZERO, light_size), Vector2i(light_position))

	# 更新迷雾的纹理对象
	fog_texture.update(fog_image)

	# 更新在着色器中的current_texture
	current_image.fill(Color.WHITE)
	current_image.blend_rect(light_image, Rect2i(Vector2.ZERO, light_size), Vector2i(light_position))
	current_texture.update(current_image)
	# 注意：这里应该使用fog_image的完整尺寸

## 验证必需的组件—检查迷雾系统初始化所需的所有组件是否正确配置
func _validate_components() -> bool:
	var is_valid = true
	var errors = []
	
	# 检查相机限制区域
	if not camera_limit:
		errors.append("camera_limit未设置")
		is_valid = false
	elif camera_limit.size.x <= 0 or camera_limit.size.y <= 0:
		errors.append("camera_limit尺寸无效: %s" % camera_limit.size)
		is_valid = false
	
	# 检查光源纹理
	if not light_texture:
		errors.append("light_texture未设置")
		is_valid = false
	
	# 检查材质
	if not material:
		errors.append("材质未设置")
		is_valid = false
	
	# 检查SMainController是否可用
	if not SMainController:
		errors.append("SMainController不可用")
		is_valid = false
	
	# 输出错误信息
	for error in errors:
		push_error("迷雾系统组件验证失败: %s" % error)
	
	return is_valid

#region 存档系统

## 保存当前迷雾状态（待实现）
func _save_as():
	pass

## 从存档恢复迷雾状态（待实现）
func _load_by():
	pass

#endregion
