extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var fog_overlay: ColorRect = $FogLayer/FogOverlay

func _ready():
	print("=== 雾天着色器测试场景 ===")
	print("控制说明：")
	print("- WASD/方向键: 移动角色")
	print("- 1/2: 调整雾密度")
	print("- 3/4: 调整雾移动速度") 
	print("- 5/6: 调整雾的缩放")
	print("- 空格键: 快速切换雾密度")
	print("- ESC键: 开关雾效果")
	print("观察雾的动态移动效果！")

func _process(_delta):
	handle_player_movement()
	handle_fog_controls()

func handle_player_movement():
	if not player:
		return
		
	var input_vector = Vector2.ZERO
	
	# 获取输入
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
		
	# 标准化输入向量以避免对角线移动过快
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
	
	# 设置速度
	var speed = 200.0
	player.velocity = input_vector * speed
	
	# 移动玩家
	player.move_and_slide()

func handle_fog_controls():
	if not fog_overlay or not fog_overlay.material:
		return
	
	var shader_material = fog_overlay.material as ShaderMaterial
	if not shader_material:
		return
	
	# 调整雾密度
	if Input.is_action_just_pressed("ui_accept"): # 空格键
		var current_density = shader_material.get_shader_parameter("fog_density")
		var new_density = 0.3 if current_density > 0.4 else 0.7
		shader_material.set_shader_parameter("fog_density", new_density)
		print("雾密度: ", new_density)
	
	# 开关雾效果
	if Input.is_action_just_pressed("ui_cancel"): # ESC键
		fog_overlay.visible = !fog_overlay.visible
		print("雾效果: ", "开启" if fog_overlay.visible else "关闭")
	
	# 数字键控制
	if Input.is_key_pressed(KEY_1):
		var density = shader_material.get_shader_parameter("fog_density")
		density = max(0.0, density - 0.5 * get_process_delta_time())
		shader_material.set_shader_parameter("fog_density", density)
	
	if Input.is_key_pressed(KEY_2):
		var density = shader_material.get_shader_parameter("fog_density")
		density = min(1.0, density + 0.5 * get_process_delta_time())
		shader_material.set_shader_parameter("fog_density", density)
		
	if Input.is_key_pressed(KEY_3):
		var fog_speed = shader_material.get_shader_parameter("fog_speed")
		fog_speed = max(0.1, fog_speed - 1.0 * get_process_delta_time())
		shader_material.set_shader_parameter("fog_speed", fog_speed)
		
	if Input.is_key_pressed(KEY_4):
		var fog_speed = shader_material.get_shader_parameter("fog_speed")
		fog_speed = min(3.0, fog_speed + 1.0 * get_process_delta_time())
		shader_material.set_shader_parameter("fog_speed", fog_speed)
	
	if Input.is_key_pressed(KEY_5):
		var fog_scale = shader_material.get_shader_parameter("fog_scale")
		fog_scale = max(0.3, fog_scale - 1.0 * get_process_delta_time())
		shader_material.set_shader_parameter("fog_scale", fog_scale)
		
	if Input.is_key_pressed(KEY_6):
		var fog_scale = shader_material.get_shader_parameter("fog_scale")
		fog_scale = min(3.0, fog_scale + 1.0 * get_process_delta_time())
		shader_material.set_shader_parameter("fog_scale", fog_scale)
