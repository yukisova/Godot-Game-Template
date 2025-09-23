extends Node2D

@export var normal_sprite: Texture2D
@export var hide_sprite: Texture2D

@export var player: CharacterBody2D
@export var collision_shape: CollisionShape2D
@export var player_sprite: Sprite2D

var context: Dictionary
var current_delta: float

func fix_movement(move_direction: String, wall_tangent: Vector2, wall_normal: Vector2) -> bool:
	# 获取物理空间状态用于射线检测
	var world_2d = player.get_world_2d()
	var space_state = world_2d.direct_space_state
	
	# 根据移动方向确定检测方向
	#var detection_direction = wall_normal
	var ray_start
	var check_size = 0
	var therehold = 3
	match move_direction:
		"左":
			ray_start = player.global_position + (collision_shape.shape.size.x / 2 + therehold) * Vector2(-1, 0)
			check_size = collision_shape.shape.size.y
		"右":
			ray_start = player.global_position + (collision_shape.shape.size.x / 2 + therehold) * Vector2(1, 0)
			check_size = collision_shape.shape.size.y
		"上":
			ray_start = player.global_position + (collision_shape.shape.size.y / 2 + therehold) * Vector2(0, -1)
			check_size = collision_shape.shape.size.x
		"下":
			ray_start = player.global_position + (collision_shape.shape.size.y / 2 + therehold) * Vector2(0, 1)
			check_size = collision_shape.shape.size.x
		"无":
			ray_start = player.global_position

	# 从玩家当前位置沿检测方向发射射线
	var ray_end = ray_start - wall_normal * check_size
	context = {
		"start":ray_start,
		"end":ray_end
	}
	queue_redraw()
	# 创建射线查询参数
	var query = PhysicsRayQueryParameters2D.create(ray_start, ray_end)
	
	query.exclude = [player.get_rid()]  # 排除玩家自己
	
	# 进行射线检测
	var result = space_state.intersect_ray(query)
	
	## 如果result为空，说明前方到了拐角，返回
	if result.is_empty():
		return true
	else:
		return false

# 分析沿墙面的移动方向
func analyze_wall_movement_direction(move_vector: Vector2, wall_normal: Vector2) -> Vector2:
	# 计算沿墙面的切线方向（垂直于法线）
	var wall_tangent = Vector2(-wall_normal.y, wall_normal.x)
	
	# 计算移动向量在切线方向上的投影（沿墙面移动的分量）
	var tangent_movement = wall_tangent.dot(move_vector)
	
	# 设置最小移动阈值，避免微小移动的误判
	var movement_threshold = 0.1
	
	var current_move_direction
	
	# 判断墙面类型和移动方向
	if abs(tangent_movement) < movement_threshold:
		# 沿墙面移动分量很小，输出"无"
		current_move_direction = "无"
		print("沿墙面移动方向：无")
	else:
		# 判断是水平墙面还是垂直墙面
		if abs(wall_normal.y) > abs(wall_normal.x):
			# 水平墙面（法线主要是垂直方向）
			if tangent_movement > 0:
				current_move_direction = "右"
				print("沿墙面移动方向：右")
			else:
				current_move_direction = "左"
				print("沿墙面移动方向：左")
		else:
			# 垂直墙面（法线主要是水平方向）
			if tangent_movement > 0:
				current_move_direction = "上"
				print("沿墙面移动方向：上")
			else:
				current_move_direction = "下"
				print("沿墙面移动方向：下")
		
		if fix_movement(current_move_direction, wall_tangent, wall_normal):
			if current_move_direction == "右" or current_move_direction == "左":
				move_vector = Vector2(0, move_vector.y)
			elif current_move_direction == "上" or current_move_direction == "下":
				move_vector = Vector2(move_vector.x, 0)
	# 如果有移动方向，检测与拐角的距离
	return move_vector


#func _draw() -> void:
	#var start = context.get("start", Vector2.ZERO)
	#var end = context.get("end", Vector2.ZERO)
	##draw_line(start, end, Color.FIREBRICK)
	#draw_circle(end, 2, Color.AQUA)

func listen_蹲下():
	if Input.is_key_pressed(KEY_SPACE) or check_player_is_in_collision():
		player.collision_mask = 0b1000
		player.collision_layer = 0b1000
		collision_shape.debug_color = Color.RED
	else:
		player.collision_mask = 0b0001
		player.collision_layer = 0b0001
		collision_shape.debug_color = Color.AQUAMARINE

func check_player_is_in_collision() -> bool:
	# 1. 判断角色的
	var world_2d = player.get_world_2d()
	var space_state = world_2d.direct_space_state
	
	var query = PhysicsShapeQueryParameters2D.new()
	query.collision_mask = 0b1
	query.exclude = [player.get_rid()]
	query.shape = collision_shape.shape.duplicate()
	query.transform = collision_shape.get_global_transform()
	
	var result = space_state.intersect_shape(query)
	
	if result.is_empty():
		return false
	else:
		return true

func _ready():
	player_sprite.texture = normal_sprite


func _process(_delta):
	listen_蹲下()
	
	var vec_info = SMainController._vec_input_8_toward(SoraConstant.InputTarget.PLAYER1)
	var move_vector = vec_info.vec
	player.velocity = move_vector * 100
	
	# 检测碰撞并切换纹理（贴墙效果）
	var should_hide = false
	
	# 检查是否有碰撞且玩家在朝障碍物方向移动
	if player.get_slide_collision_count() > 0 and move_vector.length() > 0:
		var collision = player.get_slide_collision(0)
		var collision_normal = collision.get_normal()
		current_delta += _delta
		# 计算玩家输入方向与碰撞法线的点积
		# 如果点积为负，说明玩家在朝障碍物方向移动
		var dot_product = move_vector.dot(collision_normal)
		if dot_product < 0:
			if current_delta > 0.3:
				should_hide = true
				# 分析沿墙面的移动方向
				move_vector = analyze_wall_movement_direction(move_vector, collision_normal)
		else:
			current_delta = 0
	# 根据是否需要隐藏来切换纹理
	if should_hide:
		player_sprite.texture = hide_sprite
	else:
		player_sprite.texture = normal_sprite
	player.velocity = move_vector * 100
	player.move_and_slide()
