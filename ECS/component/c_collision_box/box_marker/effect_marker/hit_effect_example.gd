extends Node2D

# 这是一个使用受击特效的示例脚本
# 展示如何在实际游戏中调用受击特效

@export var hit_effect_scene: PackedScene
var hit_effect_instance: Node2D

func _ready():
	# 实例化受击特效
	if hit_effect_scene:
		hit_effect_instance = hit_effect_scene.instantiate()
		add_child(hit_effect_instance)
		
		# 可以预设一些参数
		if hit_effect_instance.has_method("set_effect_parameters"):
			hit_effect_instance.set_effect_parameters(100, 0.8)  # 100个粒子，持续0.8秒
		if hit_effect_instance.has_method("set_particle_color"):
			hit_effect_instance.set_particle_color(Color.RED, Color.TRANSPARENT)  # 红色粒子

func _input(event):
	if event.is_action_pressed("ui_accept"):  # 按空格键测试
		test_hit_effect()

func test_hit_effect():
	if hit_effect_instance:
		# 生成一个随机方向
		var random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		
		print("播放受击特效，方向: ", random_direction)
		if hit_effect_instance.has_method("play_hit_effect"):
			hit_effect_instance.play_hit_effect(random_direction)

# 模拟角色受到攻击时调用受击特效
func on_character_hit(attack_position: Vector2, character_position: Vector2):
	if hit_effect_instance:
		# 计算受击方向（从攻击者位置指向角色位置）
		var hit_direction = (character_position - attack_position).normalized()
		
		# 播放受击特效
		if hit_effect_instance.has_method("play_hit_effect"):
			hit_effect_instance.play_hit_effect(hit_direction)

# 其他可能的使用方法：
# 1. 在敌人死亡时播放特效
func on_enemy_death():
	if hit_effect_instance:
		if hit_effect_instance.has_method("set_particle_color"):
			hit_effect_instance.set_particle_color(Color.YELLOW, Color.TRANSPARENT)
		if hit_effect_instance.has_method("play_hit_effect"):
			hit_effect_instance.play_hit_effect(Vector2.UP)

# 2. 在物体被破坏时播放特效  
func on_object_destroyed(explosion_direction: Vector2):
	if hit_effect_instance:
		if hit_effect_instance.has_method("set_effect_parameters"):
			hit_effect_instance.set_effect_parameters(200, 1.0)  # 更多粒子，更长持续时间
		if hit_effect_instance.has_method("set_particle_color"):
			hit_effect_instance.set_particle_color(Color.ORANGE, Color.TRANSPARENT)
		if hit_effect_instance.has_method("play_hit_effect"):
			hit_effect_instance.play_hit_effect(explosion_direction)
