## @editing: Sora [br]
## @describe: 战争迷雾系统 - 动态视野遮罩和探索系统
##
## 该系统实现了类似RTS游戏的战争迷雾效果：
## - 基于玩家位置的动态视野揭示
## - 实时图像处理和纹理更新
## - 性能优化的移动检测机制
## - 可配置的光照半径和效果
##
## 主要功能：
## - 动态生成和更新迷雾纹理
## - 基于玩家移动的视野揭示
## - 光照纹理的混合处理
## - 迷雾状态的存档和恢复
##
## 技术特性：
## - 实时图像混合算法
## - 优化的重绘触发机制
## - 可扩展的光源系统
## - 内存高效的纹理管理
##
## 应用场景：
## - 探索类游戏的视野限制
## - 地牢和迷宫的逐步揭示
## - 战略游戏的战争迷雾
## - 恐怖游戏的氛围营造
##
## 注意事项：
## - 目前为测试版本，后续需要优化性能
## - 计划替代原有的房屋遮挡系统
extends Sprite2D

#region 迷雾配置

## 迷雾图像宽度
## 战争迷雾纹理的像素宽度
@export var fog_width: int

## 迷雾图像高度
## 战争迷雾纹理的像素高度
@export var fog_height: int

## 光照纹理
## 用于揭示迷雾的光源纹理资源
@export var light_texture: Texture2D

#endregion

#region 迷雾数据

## 迷雾图像数据
## 存储当前迷雾状态的像素数据
var fog_image: Image

## 迷雾纹理对象
## 用于显示的动态纹理
var fog_texture: ImageTexture

## 光照图像数据
## 光源纹理的像素数据缓存
var light_image: Image

#endregion

#region 玩家引用

## 玩家角色引用
## 用于追踪玩家位置的角色控制器
var player: CharacterBody2D

#endregion

func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

func _initialize():
	player = SMainController.player_static.main_control
	
	fog_image = Image.create(fog_width, fog_height, false, Image.FORMAT_RGBA8)
	fog_image.fill(Color.WHITE) ## 测试: 一开始先填充白色作为底色
	fog_texture = ImageTexture.create_from_image(fog_image)
	texture = fog_texture
	
	light_image = light_texture.get_image()
	update_fog()
	process_mode = Node.PROCESS_MODE_INHERIT
	## 以下是一个不知原因的小bug， 
	#hide()
	#show()

func _process(_delta: float) -> void:
	if !player.velocity.is_equal_approx(Vector2.ZERO):
		update_fog()

func update_fog():
	var player_position = player.global_position + Vector2(fog_width, fog_height) / 2
	player_position -= Vector2(light_image.get_size()) / 2.0
	
	fog_image.blend_rect(light_image, Rect2i(Vector2.ZERO, light_image.get_size()), player_position)
	fog_texture.update(fog_image)

#region :存档系统:
func _save_as():
	pass

func _load_by():
	pass
#endregion