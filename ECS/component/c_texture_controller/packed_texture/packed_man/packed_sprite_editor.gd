## [b]打包人物精灵编辑器[/b]
##
## 用于在编辑器中预览和调试打包人物精灵的工具类。[br]
## 提供角色朝向控制、椭圆运动手臂动画和动态深度层次管理功能。
##
## [b]主要功能:[/b]
## [color=green]•[/color] 角色朝向控制和实时预览[br]
## [color=green]•[/color] 基于椭圆参数的手臂运动轨迹[br]
## [color=green]•[/color] 根据椭圆位置动态调整手臂z_index深度[br]
## [color=green]•[/color] 支持左右手独立的椭圆运动控制
##
## [b]编辑器特性:[/b]
## [color=yellow]•[/color] rotation_angle滑块控制角色朝向（-1到1范围）[br]
## [color=yellow]•[/color] 可配置椭圆运动参数（半径X和半径Y）[br]
## [color=yellow]•[/color] 可调整手臂偏移量[br]
## [color=yellow]•[/color] 实时可视化手臂运动轨迹
##
## [b]z_index深度管理:[/b]
## [color=red]•[/color] 椭圆上半部分（Y<0）：手臂在身体[b]后面[/b][br]
## [color=red]•[/color] 椭圆下半部分（Y≥0）：手臂在身体[b]前面[/b][br]
## [color=red]•[/color] 基于椭圆几何位置的自然深度层次
##
## [b]设计理念:[/b]
## [color=blue]•[/color] 简化复杂的角色动画制作流程[br]
## [color=blue]•[/color] 提供直观的椭圆运动参数调试[br]
## [color=blue]•[/color] 实现自然的深度层次视觉效果
##
## [br][b]编辑者:[/b] [color=purple]Sora[/color]
@tool
class_name PackedSpriteEditor
extends Node

## [b]角色朝向角度[/b] [color=gray](范围: -1到1)[/color]
## 
## 控制角色的朝向，自动更新RayCast2D的旋转和调用toward方法。
## [color=green]•[/color] [code]-1[/code]: 向左[br]
## [color=green]•[/color] [code]0[/code]: 向前[br]
## [color=green]•[/color] [code]1[/code]: 向右


@export_range(-0.5,0.5) var rotation_angle: float = 0.0:
	set(value):
		rotation_angle = value
		if is_node_ready():
			toward(Vector2.RIGHT.rotated(-rotation_angle * 2 * PI))

## [b]控制部件字典[/b]
## 
## 存储角色各个部位的Node2D引用，用于纹理控制和动画管理。[br]
## [b]常用键名:[/b]
## [color=yellow]•[/color] [code]"Body"[/code]: 身体精灵[br]
## [color=yellow]•[/color] [code]"Head"[/code]: 头部精灵[br]
## [color=yellow]•[/color] [code]"Left"[/code]: 左手精灵[br]
## [color=yellow]•[/color] [code]"Right"[/code]: 右手精灵
@export var control_parts: Dictionary[StringName, Node2D]

## [b]手部偏移量[/b]
## 
## 手臂椭圆运动的基础偏移位置，相对于身体中心的偏移量。[br]
## 默认值为[code]Vector2(0, -50)[/code]，即向上偏移[color=green]50[/color]个像素。
@export var hand_offset: Vector2 = Vector2(0,-50)

## [b]主精灵部件[/b]
## 
## [color=blue]IPackedSprite[/color]类型的主要精灵组件引用。
var main_part: IPackedSprite

## [b]纹理朝向[/b]
## 
## 当前角色的朝向方向向量，用于控制精灵翻转和帧切换。[br]
## 默认为[code]Vector2.RIGHT[/code]（向右），会根据[code]rotation_angle[/code]更新。
#var texture_award: Vector2 = Vector2.RIGHT

## [color=orange][b]椭圆参数组[/b][/color]
## 
## 控制手臂椭圆运动轨迹的参数设置。
@export_group("椭圆参数", "ellipse_body_")

## [b]椭圆X轴半径[/b]
## 
## 手臂椭圆运动在X轴方向的半径大小。[br]
## 值越大，手臂[color=red]左右摆动幅度[/color]越大。
@export var ellipse_body_radius_x: float = 100.0

## [b]椭圆Y轴半径[/b]
## 
## 手臂椭圆运动在Y轴方向的半径大小。[br]
## 值越大，手臂[color=red]上下摆动幅度[/color]越大。
@export var ellipse_body_radius_y: float = 50.0


## [b]初始化方法[/b]
## 
## 在节点准备就绪时调用，初始化主精灵部件的引用。
func _initialize():
	main_part = get_parent() as IPackedSprite

## [b]角色朝向控制方法[/b]
## 
## 根据给定的方向向量更新角色各部位的朝向和显示状态。[br]
## 同时触发手臂的椭圆运动更新。
##
## [b]参数:[/b] [code]direction[/code] 朝向方向向量，通常为标准化的Vector2
##
## [b]功能详述:[/b]
## [color=green]•[/color] 更新身体和头部的[b]水平翻转[/b]状态[br]
## [color=green]•[/color] 根据Y方向分量切换身体和头部的[b]帧[/b][br]
## [color=green]•[/color] 计算并更新左右手的[b]椭圆运动[/b]位置[br]
## [color=blue]•[/color] 左手相对于朝向[color=yellow]逆时针偏移90度[/color][br]
## [color=blue]•[/color] 右手相对于朝向[color=yellow]顺时针偏移90度[/color]
func toward(direction: Vector2) -> void:
	var sprite_body: Sprite2D = control_parts.get(&"Body", null)
	var sprite_head: Sprite2D = control_parts.get(&"Head", null)

	if sprite_body == null or sprite_head == null:
		printerr("sprite_body or sprite_head is null")
		return

	# 根据X方向设置水平翻转
	sprite_body.flip_h = direction.x > 0.0
	sprite_head.flip_h = direction.x > 0.0
	
	# 根据Y方向设置帧（0=正面/上, 1=背面/下）
	sprite_body.frame = 0 if direction.y >= -0.1 else 1
	sprite_head.frame = 0 if direction.y >= -0.1 else 1
	
	# 更新左右手椭圆运动
	# 左手相对于朝向逆时针偏移90度 (-PI/2.0)
	update_hands_rotation(hand_offset, control_parts.get(&"Left", null), direction.rotated(-PI / 2.0).angle())
	# 右手相对于朝向顺时针偏移90度 (PI/2.0)
	update_hands_rotation(hand_offset, control_parts.get(&"Right", null), direction.rotated(PI / 2.0).angle())


	
## [b]手臂椭圆运动更新方法[/b]
## 
## 根据椭圆参数和角度更新手臂的位置、旋转和深度层次。[br]
## 实现基于椭圆轨迹的[color=green]自然手臂摆动动画效果[/color]。
##
## [b]参数:[/b]
## [color=yellow]•[/color] [code]offset[/code] 基础偏移量，手臂椭圆运动的中心点偏移[br]
## [color=yellow]•[/color] [code]base[/code] 目标手臂节点，要更新的Node2D对象[br]
## [color=yellow]•[/color] [code]angle[/code] 椭圆运动角度（弧度），决定手臂在椭圆轨迹上的位置
##
## [b]椭圆运动计算:[/b]
## [color=blue]•[/color] X坐标 = [code]ellipse_body_radius_x * cos(angle)[/code][br]
## [color=blue]•[/color] Y坐标 = [code]ellipse_body_radius_y * sin(angle)[/code][br]
## [color=blue]•[/color] 最终位置 = [code]offset + 椭圆位置[/code]
##
## [b]z_index深度管理:[/b]
## [color=red]•[/color] 椭圆上半部分 [color=gray](Y < 0)[/color]: 手臂在身体[b]后面[/b] [color=gray](z_index-1)[/color][br]
## [color=red]•[/color] 椭圆下半部分 [color=gray](Y ≥ 0)[/color]: 手臂在身体[b]前面[/b] [color=gray](z_index+1)[/color][br]
## [color=red]•[/color] 基于椭圆几何位置实现[color=green]自然的深度层次[/color]效果
##
## [b]使用场景:[/b]
## [color=purple]•[/color] 角色行走时的手臂摆动[br]
## [color=purple]•[/color] 角色转身时的手臂跟随[br]
## [color=purple]•[/color] 任何需要自然手臂运动的动画
func update_hands_rotation(offset: Vector2, base: PackedPart, angle: float) -> void:
	if base == null:
		printerr("base node is null")
		return
	
	# 根据椭圆参数计算手臂在椭圆轨迹上的位置
	var ellipse_x = ellipse_body_radius_x * cos(angle)
	var ellipse_y = ellipse_body_radius_y * sin(angle)
	var ellipse_position = Vector2(ellipse_x, ellipse_y)
	
	# 应用基础偏移量和椭圆位置，确定手臂最终位置
	base.position = offset + ellipse_position
	
	# 根据椭圆位置动态调整z_index实现深度层次
	var sprite_body: Sprite2D = control_parts.get(&"Body", null)
	if sprite_body != null:
		var body_z_index = sprite_body.z_index
		
		# 计算手臂在椭圆轨迹上的Y坐标
		var hand_ellipse_y = ellipse_body_radius_y * sin(angle)
		
		# 基于椭圆Y坐标判断手臂的深度层次
		# 上半椭圆(向上)：手臂在身体后面，下半椭圆(向下)：手臂在身体前面
		if hand_ellipse_y < 0:
			base.z_index = body_z_index - 1  # 在身体后面
		else:
			base.z_index = body_z_index + 1  # 在身体前面
		
		if base.sprite and base.sprite is AttackNode:
			if abs(rotation_angle) > 0.25:
				base.sprite.fixed_flip_v = true
			else:
				base.sprite.fixed_flip_v = false
