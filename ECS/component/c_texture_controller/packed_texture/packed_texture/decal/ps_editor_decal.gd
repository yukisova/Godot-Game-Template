@tool
class_name PSEditorDecal
extends PackedSpriteEditor

## 当前子弹的高度，根据它来判断纹理与地面的距离，进而判断是否与目标碰撞
@export_range(0,1) var current_range_ratio: float:
	set(value):
		current_range_ratio = value
		if is_node_ready():
			_change_height(value)

#region 工具按钮
@export var fixed_body_y: int:
	set(v):
		fixed_body_y = v
		if Engine.is_editor_hint():
			fixed_packed_sprite()

@export_tool_button("快速校准位置") var quick_fixed = fixed_packed_sprite

## 根据设定的精灵躯干的参数，快速校准精灵各个部位的位置
func fixed_packed_sprite():
	var body = control_parts.get(&"Main", null).get_parent() as Node2D
	body.position = Vector2(0, fixed_body_y)
#endregion

@export var path_node: Curve2D 

@export var decal_image: Array[Texture2D]

func _change_height(value: float):
	control_parts.get(&"Main").position.y = path_node.sample(0, value).y

func _initialize():
	_change_height(current_range_ratio)

	var c_texture_controller: CTextureController = main_part.c_texture_controller as CTextureController
	c_texture_controller.component_owner.despawned.connect(_before_destroy)


## 当血滴落入地面时 - 使用SoraEvent优化的图像处理
func _body_on_floor():
	var body: Node2D = control_parts["Main"]
	body.visible = false
	
	# 检查decal_image数组是否有效
	if decal_image.is_empty():
		print("警告：decal_image数组为空，无法显示decal效果")
		return
	
	var rand_decal_index = randi_range(0, decal_image.size() - 1)
	var rand_angle = randi_range(0, 360)
	var rand_scale = randf_range(0.8, 1.5)
	
	# 使用SoraEvent的优化图像处理（带缓存）
	var original_image = decal_image[rand_decal_index].get_image()
	var processed_image = SoraEvent.process_decal_image_cached(
		original_image,
		rand_angle,
		rand_scale,
		Color.RED,
		Vector2i(64, 32)
	)
	
	# 应用到地面
	if SMapData.current_level:
		SMapData.current_level.try_paint_floor(main_part.shadow.global_position, processed_image)

func _before_destroy(_entity: TempEntity):
	_body_on_floor()

func _update(_delta: float):
	pass