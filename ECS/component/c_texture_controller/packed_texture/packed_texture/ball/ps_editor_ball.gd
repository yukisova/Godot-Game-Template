@tool
extends PackedSpriteEditor

enum HandMoveType {
	ELLIPSE, ## 两手部以椭圆轨迹运动(类老p的演示)
	LINE, ## 两手同步进行左右的位移(类元气骑士)
}
## 角色朝向角度，控制角色的朝向并自动调用toward方法，范围-0.5到0.5
@export_range(-0.5,0.5) var rotation_angle: float = -0.3:
	set(value):
		rotation_angle = value
		if is_node_ready():
			toward(Vector2.RIGHT.rotated(-rotation_angle * 2 * PI))

## 手部偏移量，手臂椭圆运动的基础偏移位置，相对于身体中心的偏移量
@export var hand_offset_y: float = -50

@export var hand_move_type: HandMoveType = HandMoveType.ELLIPSE:
	set(value):
		hand_move_type = value
		notify_property_list_changed()



## 椭圆参数组，控制手臂椭圆运动轨迹的参数设置
@export_group("椭圆参数", "ellipse_body_")

## 椭圆X轴半径，手臂椭圆运动在X轴方向的半径大小，值越大左右摆动幅度越大
@export_range(0.0, 1, 0.5, "or_greater") var ellipse_body_radius_x: float = 100.0

## 椭圆Y轴半径，手臂椭圆运动在Y轴方向的半径大小，值越大上下摆动幅度越大
@export_range(0.0, 1, 0.5, "or_greater") var ellipse_body_radius_y: float = 50.0

#region 工具按钮
@export var fixed_body_y: int:
	set(v):
		fixed_body_y = v
		if Engine.is_editor_hint():
			if is_node_ready():
				fixed_packed_sprite()
@export_tool_button("快速校准躯干位置") var quick_fixed = fixed_packed_sprite

## 根据设定的精灵躯干的参数，快速校准精灵各个部位的位置
func fixed_packed_sprite():
	var body = control_parts.get(&"Body", null)

	if body == null:
		printerr("Body 部件未找到，无法进行快速校准")
		return
		
	if body.texture == null:
		printerr("Body 部件的纹理为空，无法进行快速校准")
		return
		
	var body_sprite_size = body.texture.get_size().y

	body.position = Vector2(0, -body_sprite_size + fixed_body_y)
	
	rotation_angle = -0.3
	var hand_left: PackedPart = control_parts.get(&"Left", null)
	var hand_right: PackedPart = control_parts.get(&"Right", null)
	
	if hand_left != null:
		hand_left.back_to_default()
	else:
		printerr("Left 手部部件未找到，跳过左手重置")
		
	if hand_right != null:
		hand_right.back_to_default()
	else:
		printerr("Right 手部部件未找到，跳过右手重置")
#endregion

## 初始化方法，在节点准备就绪时调用，初始化主精灵部件的引用
func _initialize():
	super()
	rotation_angle = -0.3

func _update(_delta: float) -> void:
	for part in control_parts.values():
		if part is PackedPart:
			part._update(_delta)

## 角色朝向控制方法，根据给定的方向向量更新角色各部位的朝向和显示状态，同时触发手臂的椭圆运动更新
## [param direction]: 朝向方向向量，通常为标准化的Vector2
func toward(direction: Vector2) -> void:
	var sprite_body: Sprite2D = control_parts.get(&"Body", null)

	if sprite_body == null:
		printerr("sprite_body is null")
		return

	# 根据X方向设置水平翻转
	sprite_body.flip_h = direction.x > 0.0
	
	# 根据Y方向设置帧（0=正面/上, 1=背面/下）
	sprite_body.frame = 0 if direction.y >= -0.1 else 1

	if hand_move_type == HandMoveType.ELLIPSE:
		update_hands_rotation(direction, Vector2(0, hand_offset_y), control_parts.get(&"Left", null), direction.rotated(-PI / 2.0).angle(), true)
		update_hands_rotation(direction, Vector2(0, hand_offset_y), control_parts.get(&"Right", null), direction.rotated(PI / 2.0).angle(), false)
	#elif hand_move_type == HandMoveType.LINE:
		#update_hands_rotation(direction, Vector2(hand_offset_x_left, hand_offset_y), control_parts.get(&"Left", null), direction.angle(), true)
		#update_hands_rotation(direction, Vector2(hand_offset_x_right, hand_offset_y), control_parts.get(&"Right", null), direction.angle(), false)

## 手臂椭圆运动更新方法，根据椭圆参数和角度更新手臂的位置、旋转和深度层次，实现基于椭圆轨迹的自然手臂摆动动画效果
## [param offset]: 基础偏移量，手臂椭圆运动的中心点偏移
## [param base]: 目标手臂节点，要更新的PackedPart对象
## [param angle]: 椭圆运动角度（弧度），决定手臂在椭圆轨迹上的位置
## [param left_or_right]: 是否是左手，true为左手，false为右手
func update_hands_rotation(direction: Vector2, offset: Vector2, base: PackedPart, angle: float, left_or_right: bool = true) -> void:
	if base == null:
		printerr("base node is null")
		return

	match hand_move_type:
		HandMoveType.ELLIPSE:
			base.x_基础长轴 = ellipse_body_radius_x
			base.x_基础短轴 = ellipse_body_radius_y
			base.x_基础轨道旋转 = angle
			base.x_基础位置 = offset
			base.x_基础方向 = direction
			# 根据椭圆位置动态调整z_index实现深度层次
			var sprite_body: Sprite2D = control_parts.get(&"Body", null)
			if sprite_body != null:
				base.x_身体z轴 = sprite_body.z_index
	
			if base.sprite is EquipmentNode:
				# EquipmentNode类型：根据角度阈值设置垂直翻转
				var should_flip = abs(rotation_angle) > 0.25
				base.x_纹理反转 = should_flip != left_or_right
				if (!base.x_竖握) and (!base.x_反握):
					base.x_基础纹理旋转 = direction.angle()
			else:
				# 普通精灵：根据角度和手部位置设置水平翻转
				var should_flip = rotation_angle < 0
				base.x_纹理反转 = should_flip != left_or_right

#region 纹理切换命令
## 位于texture_switch_command中的信息: 
func _initialize_texture_switch_command():
	texture_switch_command["Hiding"] = func():
		var texture_switch_record = texture_lib.find(control_parts["Body"], "Hiding")
		if texture_switch_record != null:
			control_parts["Body"].texture = texture_switch_record

	texture_switch_command["Normal"] = func():
		var texture_switch_record = texture_lib.find(control_parts["Body"], "Normal")
		if texture_switch_record != null:
			control_parts["Body"].texture = texture_switch_record
#endregion
