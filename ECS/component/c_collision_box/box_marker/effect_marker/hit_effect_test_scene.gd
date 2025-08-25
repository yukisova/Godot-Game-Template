extends Node2D

@export var hit_effect_scene: PackedScene
@onready var instructions_label = $UI/Instructions
@onready var counter_label = $UI/EffectCounter
@onready var camera = $Camera2D

var effect_instances: Array[Node2D] = []
var effect_count: int = 0

func _ready():
	print("受击特效测试场景已启动!")
	print("使用鼠标左键点击屏幕来测试特效")
	
	# 设置相机位置
	camera.enabled = true
	
	# 更新说明文本
	update_counter()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# 将屏幕坐标转换为世界坐标
			var world_pos = camera.get_global_mouse_position()
			play_effect_at_position(world_pos)
	
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE:
				# 空格键：在中心播放向上的特效
				play_effect_at_position(Vector2.ZERO, Vector2.UP, Color.WHITE)
				
			KEY_1:
				# 1键：红色受击特效
				var random_pos = Vector2(randf_range(-200, 200), randf_range(-200, 200))
				var direction = Vector2(randf_range(-1, 1), randf_range(-0.5, 0.5)).normalized()
				play_effect_at_position(random_pos, direction, Color.RED)
				
			KEY_2:
				# 2键：黄色爆炸特效
				var random_pos = Vector2(randf_range(-200, 200), randf_range(-200, 200))
				play_effect_at_position(random_pos, Vector2.UP, Color.YELLOW, 100, 1.0)
				
			KEY_3:
				# 3键：蓝色冰霜特效
				var random_pos = Vector2(randf_range(-200, 200), randf_range(-200, 200))
				var direction = Vector2(randf_range(-1, 1), randf_range(-1, -0.2)).normalized()
				play_effect_at_position(random_pos, direction, Color.CYAN, 30, 0.3)
				
			KEY_R:
				# R键：随机特效
				var random_pos = Vector2(randf_range(-300, 300), randf_range(-300, 300))
				var random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
				var random_color = Color(randf(), randf(), randf())
				var random_count = randi_range(20, 150)
				var random_duration = randf_range(0.3, 1.5)
				play_effect_at_position(random_pos, random_direction, random_color, random_count, random_duration)
				
			KEY_C:
				# C键：清理所有特效
				clear_all_effects()
				
			KEY_ESCAPE:
				# ESC键：退出测试场景
				get_tree().quit()

func play_effect_at_position(
	effect_position: Vector2, 
	direction: Vector2 = Vector2.ZERO, 
	color: Color = Color.WHITE,
	particle_count: int = 50,
	duration: float = 0.5
):
	if not hit_effect_scene:
		print("错误：未设置受击特效场景!")
		return
	
	# 创建特效实例
	var effect_instance = hit_effect_scene.instantiate()
	add_child(effect_instance)
	
	# 设置位置
	effect_instance.global_position = effect_position
	
	# 配置特效参数
	if effect_instance.has_method("set_effect_parameters"):
		effect_instance.set_effect_parameters(particle_count, duration)
	
	if effect_instance.has_method("set_particle_color"):
		effect_instance.set_particle_color(color, Color.TRANSPARENT)
	
	# 播放特效
	if effect_instance.has_method("play_hit_effect"):
		# 如果没有指定方向，则根据位置计算一个合理的方向
		var effect_direction = direction
		if direction == Vector2.ZERO:
			# 从中心向外的方向
			effect_direction = (effect_position - Vector2.ZERO).normalized()
			if effect_direction == Vector2.ZERO:
				effect_direction = Vector2.UP
		
		effect_instance.play_hit_effect(effect_direction)
	
	# 添加到实例列表
	effect_instances.append(effect_instance)
	
	# 更新计数器
	effect_count += 1
	update_counter()
	
	# 在特效结束后自动清理（延迟比特效持续时间多一点）
	await get_tree().create_timer(duration + 0.5).timeout
	if is_instance_valid(effect_instance):
		effect_instances.erase(effect_instance)
		effect_instance.queue_free()

func clear_all_effects():
	print("清理所有特效...")
	for effect in effect_instances:
		if is_instance_valid(effect):
			effect.queue_free()
	effect_instances.clear()

func update_counter():
	if counter_label:
		counter_label.text = "特效播放次数: " + str(effect_count)

func _on_tree_exiting():
	clear_all_effects()

# 添加一些视觉反馈
func _draw():
	# 绘制一个简单的网格作为参考
	var viewport_size = get_viewport().size
	var grid_size = 50
	
	for x in range(-viewport_size.x, viewport_size.x, grid_size):
		draw_line(Vector2(x, -viewport_size.y), Vector2(x, viewport_size.y), Color.WHITE, 1.0, true)
	
	for y in range(-viewport_size.y, viewport_size.y, grid_size):
		draw_line(Vector2(-viewport_size.x, y), Vector2(viewport_size.x, y), Color.WHITE, 1.0, true)

func _process(_delta):
	# 持续重绘以显示网格
	queue_redraw()
