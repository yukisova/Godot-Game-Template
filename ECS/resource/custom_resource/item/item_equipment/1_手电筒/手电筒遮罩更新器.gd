## 手电筒遮罩系统更新器
## 用于在手电筒的范围内显示一些被要求隐藏的物体，用于恐怖游戏中的影子敌人
## 这类敌人的特点是无法被肉眼看见，但是可以通过某些手段看见，比如手电筒的光线
## [br][b]编辑者:[/b] Sora
@tool
extends Node

@export var mask_sprite: PointLight2D

var be_mask_sprites: Array :
	get:
		if is_node_ready():
			return SMapData.current_level.entity_state_manager.hidding_entities.entities
		return []

## 材质
## 所有的被遮罩的精灵都使用同一个着色器和材质
var mask_material: ShaderMaterial

# 遮罩参数
@export var mask_strength: float = 1.0 : set = set_mask_strength
@export var invert_mask: bool = false : set = set_invert_mask

var is_initialized: bool = false

func _process(_delta):
	if !is_initialized and Main.entity_initialzable:
		initialize()
		is_initialized = true
	
	# 在编辑器中减少更新频率，避免不必要的计算
	if Engine.is_editor_hint():
		# 只在编辑器中偶尔更新
		if randf() < 0.1:  # 10% 的概率更新
			update_mask_parameters()
	else:
		# 游戏运行时每帧更新
		update_mask_parameters()

func _exit_tree() -> void:
	if Engine.is_editor_hint(): return
	SMapData.current_level.entity_state_manager.hidding_entities.reset()

## 自定义初始化方法
func initialize():
	mask_material = SMapData.current_level.entity_state_manager.hidding_entities.hidding_material
	SMapData.current_level.entity_state_manager.hidding_entities.setup()

func update_mask_parameters():
	# 检查所有必要的对象是否存在
	if not mask_material or not mask_sprite or not be_mask_sprites:
		return
	
	# 检查遮罩纹理是否存在
	if not mask_sprite.texture:
		return
	
	# 检查着色器是否存在
	if not mask_material.shader:
		return
	
	# 设置遮罩纹理
	mask_material.set_shader_parameter("mask_texture", mask_sprite.texture)
	# 设置遮罩变换参数
	update_mask_transform_parameters()
	
	# 设置遮罩强度和反转参数
	mask_material.set_shader_parameter("mask_strength", mask_strength)
	mask_material.set_shader_parameter("invert_mask", invert_mask)

func update_mask_transform_parameters():
	if not mask_material or not mask_sprite:
		return
	
	# 获取遮罩的全局变换
	var mask_transform = mask_sprite.global_transform
	
	# 设置位置
	mask_material.set_shader_parameter("mask_position", mask_transform.origin)
	
	# 设置缩放（考虑纹理尺寸）
	var texture_size = mask_sprite.texture.get_size()
	var mask_scale_value = mask_transform.get_scale() * texture_size
	mask_material.set_shader_parameter("mask_scale", mask_scale_value)
	
	# 设置旋转
	var mask_rotation_value = mask_transform.get_rotation()
	mask_material.set_shader_parameter("mask_rotation", mask_rotation_value)
	
	# 设置偏移（考虑Sprite2D的offset属性）
	var mask_offset_value = mask_sprite.offset * mask_transform.get_scale()
	mask_material.set_shader_parameter("mask_offset", mask_offset_value)

# Setter函数，用于在编辑器中实时预览效果
func set_mask_strength(value: float):
	mask_strength = value
	if mask_material and mask_material.shader:
		mask_material.set_shader_parameter("mask_strength", mask_strength)

func set_invert_mask(value: bool):
	invert_mask = value
	if mask_material and mask_material.shader:
		mask_material.set_shader_parameter("invert_mask", invert_mask)
