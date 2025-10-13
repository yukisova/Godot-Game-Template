## 手电筒的装备节点
@tool
extends EquipmentNode

var is_aiming_focus: bool = false 

@export var point_light: PointLight2D

var timer: Timer

func _ready() -> void:
	point_light.flash_light = self
	timer = Timer.new()
	add_child(timer)

	timer.timeout.connect(trigger_effect_success)

func _trigger_effect_run(..._args) -> bool:
	timer.wait_time = 0.1
	timer.one_shot = false

	timer.start()	
	is_aiming_focus = true

	return true

func _trigger_effect_finish(..._args):
	timer.stop()
	is_aiming_focus = false

func _activated():
	pass

func _deactivated():
	pass

func trigger_effect_success():
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = point_light.light_radius
	var mouse_pos = SoraEvent.fixed_camera_position(c_status.component_body)["world_mouse_pos"]	

	var _transform: Transform2D = point_light.get_global_transform()
	_transform.x = mouse_pos.x
	_transform.y = mouse_pos.y

	var world = get_world_2d()
	var space_state = world.direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = circle
	query.transform = _transform
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.exclude = [c_status.component_body.get_rid()]

	var results = space_state.intersect_shape(query)

	for result in results:
		var target = result.collider
		if target is Hurtbox:
			print(target.c_collision.component_owner.name, "受到了照射")
			


func set_normal_type():
	point_light.flash_light_mode = 0

func set_aim_type():
	point_light.flash_light_mode = 1
