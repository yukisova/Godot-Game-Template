## DampedSpringJoint2D 测试场景脚本
## 演示 DampedSpringJoint2D 阻尼弹簧关节的用法
extends Node2D

@export var rest_length: float = 100.0 ## 弹簧自然长度
@export var stiffness: float = 50.0 ## 弹簧刚度
@export var damping: float = 1.0 ## 阻尼系数
@export var disable_collision: bool = false ## 是否禁用碰撞

@onready var spring_joint: DampedSpringJoint2D = $DampedSpringJoint2D
@onready var body_a: RigidBody2D = $BodyA
@onready var body_b: RigidBody2D = $BodyB
@onready var info: Label = $CanvasLayer/Info
@onready var rest_length_slider: HSlider = $CanvasLayer/UI/RestLengthSlider
@onready var stiffness_slider: HSlider = $CanvasLayer/UI/StiffnessSlider
@onready var damping_slider: HSlider = $CanvasLayer/UI/DampingSlider
@onready var collision_checkbox: CheckBox = $CanvasLayer/UI/CollisionCheckbox

func _ready() -> void:
	_setup_ui()
	_update_spring_joint()
	_update_info()

func _process(_delta: float) -> void:
	_update_info()

func _setup_ui() -> void:
	# 检查 UI 控件是否存在
	if rest_length_slider:
		rest_length_slider.min_value = 50.0
		rest_length_slider.max_value = 300.0
		rest_length_slider.value = rest_length
		rest_length_slider.value_changed.connect(_on_rest_length_changed)
	
	if stiffness_slider:
		stiffness_slider.min_value = 1.0
		stiffness_slider.max_value = 200.0
		stiffness_slider.value = stiffness
		stiffness_slider.value_changed.connect(_on_stiffness_changed)
	
	if damping_slider:
		damping_slider.min_value = 0.0
		damping_slider.max_value = 10.0
		damping_slider.value = damping
		damping_slider.value_changed.connect(_on_damping_changed)
	
	if collision_checkbox:
		collision_checkbox.button_pressed = disable_collision
		collision_checkbox.toggled.connect(_on_collision_changed)

func _on_rest_length_changed(value: float) -> void:
	rest_length = value
	_update_spring_joint()

func _on_stiffness_changed(value: float) -> void:
	stiffness = value
	_update_spring_joint()

func _on_damping_changed(value: float) -> void:
	damping = value
	_update_spring_joint()

func _on_collision_changed(button_pressed: bool) -> void:
	disable_collision = button_pressed
	_update_spring_joint()

func _update_spring_joint() -> void:
	if spring_joint:
		spring_joint.rest_length = rest_length
		spring_joint.stiffness = stiffness
		spring_joint.damping = damping
		spring_joint.disable_collision = disable_collision

func _update_info() -> void:
	if info:
		var current_length = body_a.global_position.distance_to(body_b.global_position) if body_a and body_b else 0.0
		var force = spring_joint.get_force() if spring_joint else 0.0
		info.text = "DampedSpringJoint2D 测试\n自然长度: %.1f | 刚度: %.1f | 阻尼: %.1f\n当前长度: %.1f | 弹簧力: %.1f | 碰撞: %s" % [
			rest_length,
			stiffness,
			damping,
			current_length,
			force,
			"禁用" if disable_collision else "启用"
		]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				# 重置弹簧参数
				rest_length = 100.0
				stiffness = 50.0
				damping = 1.0
				disable_collision = false
				_update_ui_from_values()
				_update_spring_joint()
			KEY_2:
				# 软弹簧设置
				rest_length = 150.0
				stiffness = 20.0
				damping = 2.0
				_update_ui_from_values()
				_update_spring_joint()
			KEY_3:
				# 硬弹簧设置
				rest_length = 80.0
				stiffness = 100.0
				damping = 0.5
				_update_ui_from_values()
				_update_spring_joint()
			KEY_4:
				# 无阻尼弹簧
				rest_length = 120.0
				stiffness = 60.0
				damping = 0.0
				_update_ui_from_values()
				_update_spring_joint()
			KEY_5:
				# 高阻尼弹簧
				rest_length = 100.0
				stiffness = 40.0
				damping = 5.0
				_update_ui_from_values()
				_update_spring_joint()
			KEY_6:
				# 切换碰撞
				disable_collision = !disable_collision
				if collision_checkbox:
					collision_checkbox.button_pressed = disable_collision
				_update_spring_joint()
			KEY_R:
				# 重置物体位置
				if body_a:
					body_a.global_position = Vector2(400, 300)
					body_a.linear_velocity = Vector2.ZERO
					body_a.angular_velocity = 0.0
				if body_b:
					body_b.global_position = Vector2(500, 300)
					body_b.linear_velocity = Vector2.ZERO
					body_b.angular_velocity = 0.0

func _update_ui_from_values() -> void:
	if rest_length_slider:
		rest_length_slider.value = rest_length
	if stiffness_slider:
		stiffness_slider.value = stiffness
	if damping_slider:
		damping_slider.value = damping
	if collision_checkbox:
		collision_checkbox.button_pressed = disable_collision
