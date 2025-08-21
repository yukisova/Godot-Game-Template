extends Node2D
class_name HitEffect

@onready var gpu_particles: GPUParticles2D = $GPUParticles2D

# 受击特效的默认参数
var default_direction: Vector2 = Vector2.UP
var effect_duration: float = 0.5
var particle_count: int = 50

func _ready():
	# 设置粒子系统的基本参数
	if gpu_particles:
		setup_particle_material()

func setup_particle_material():
	# 创建粒子材质
	var particle_material = ParticleProcessMaterial.new()
	
	# 设置发射方向和扩散角度
	particle_material.direction = Vector3(default_direction.x, default_direction.y, 0)
	particle_material.initial_velocity_min = 50.0
	particle_material.initial_velocity_max = 150.0
	
	# 设置重力
	particle_material.gravity = Vector3(0, 98, 0)
	
	# 设置扩散角度
	particle_material.spread = 45.0
	
	# 设置颜色渐变
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color.WHITE)
	gradient.add_point(1.0, Color.TRANSPARENT)
	
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	particle_material.color_ramp = gradient_texture
	
	# 应用材质
	gpu_particles.process_material = particle_material
	
	# 设置发射数量和模式
	gpu_particles.amount = particle_count
	gpu_particles.lifetime = 1.0  # 粒子生命周期设置在GPUParticles2D上
	gpu_particles.emitting = false
	gpu_particles.one_shot = false  # 设置为连续发射模式

# 主要函数：播放受击特效
# direction: Vector2 - 受击方向，用于确定粒子飞散的方向
func play_hit_effect(direction: Vector2 = Vector2.ZERO):
	if not gpu_particles:
		push_error("GPUParticles2D节点未找到!")
		return
	
	# 如果方向为零向量，使用默认方向
	var effect_direction = direction if direction != Vector2.ZERO else default_direction
	
	# 更新粒子材质的方向
	if gpu_particles.process_material is ParticleProcessMaterial:
		var particle_material = gpu_particles.process_material as ParticleProcessMaterial
		particle_material.direction = Vector3(effect_direction.x, effect_direction.y, 0)
		
		# 根据方向调整发射角度，让粒子更自然地向受击方向散开
		particle_material.spread = 45.0  # 扩散角度
	
	# 开始发射粒子
	gpu_particles.restart()
	gpu_particles.emitting = true
	
	# 在效果结束后自动停止
	await get_tree().create_timer(effect_duration).timeout
	gpu_particles.emitting = false

# 设置粒子特效的参数
func set_effect_parameters(particle_amount: int = 50, duration: float = 0.5):
	particle_count = particle_amount
	effect_duration = duration
	
	if gpu_particles:
		gpu_particles.amount = particle_count
		# 发射持续时间通过代码逻辑控制，不是材质属性

# 设置粒子的颜色
func set_particle_color(start_color: Color, end_color: Color = Color.TRANSPARENT):
	if not gpu_particles or not gpu_particles.process_material is ParticleProcessMaterial:
		return
	
	var particle_material = gpu_particles.process_material as ParticleProcessMaterial
	var gradient = Gradient.new()
	gradient.add_point(0.0, start_color)
	gradient.add_point(1.0, end_color)
	
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	particle_material.color_ramp = gradient_texture
