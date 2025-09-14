extends Node2D
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_UP):
		gpu_particles_2d.process_material.direction = Vector3.UP
		gpu_particles_2d.emitting = true
	elif Input.is_key_pressed(KEY_DOWN):
		gpu_particles_2d.process_material.direction = Vector3.DOWN
		gpu_particles_2d.emitting = true
	elif Input.is_key_pressed(KEY_LEFT):
		gpu_particles_2d.process_material.direction = Vector3.LEFT
		gpu_particles_2d.emitting = true
	elif Input.is_key_pressed(KEY_RIGHT):
		gpu_particles_2d.process_material.direction = Vector3.RIGHT
		gpu_particles_2d.emitting = true
	
