## PinJoint2D 测试场景脚本
## 演示 PinJoint2D 销关节的用法和参数调整
extends Node2D

@export var softness: float = 0.0 ## 关节软度 (0.0-1.0)
@export var bias: float = 0.2 ## 关节偏差
# 注意：PinJoint2D 在 Godot 4.x 中没有 max_force 属性
# 使用 softness 和 bias 来控制关节行为
@export var disable_collision: bool = false ## 是否禁用碰撞

@onready var pin_joint: PinJoint2D = $PinJoint2D
@onready var body_a: RigidBody2D = $BodyA
@onready var body_b: RigidBody2D = $BodyB
@onready var info: Label = $CanvasLayer/Info
@onready var softness_slider: HSlider = $CanvasLayer/UI/SoftnessSlider
@onready var bias_slider: HSlider = $CanvasLayer/UI/BiasSlider
# 移除 max_force_slider，因为 PinJoint2D 不支持 max_force 属性
@onready var collision_checkbox: CheckBox = $CanvasLayer/UI/CollisionCheckbox

func _ready() -> void:
	_setup_ui()
	_update_pin_joint()
	_update_info()

func _process(_delta: float) -> void:
	_update_info()

func _setup_ui() -> void:
	# 检查 UI 控件是否存在
	if softness_slider:
		softness_slider.min_value = 0.0
		softness_slider.max_value = 1.0
		softness_slider.value = softness
		softness_slider.value_changed.connect(_on_softness_changed)
	
	if bias_slider:
		bias_slider.min_value = 0.0
		bias_slider.max_value = 1.0
		bias_slider.value = bias
		bias_slider.value_changed.connect(_on_bias_changed)
	
	# 移除 max_force 相关设置，因为 PinJoint2D 不支持此属性
	
	if collision_checkbox:
		collision_checkbox.button_pressed = disable_collision
		collision_checkbox.toggled.connect(_on_collision_changed)

func _on_softness_changed(value: float) -> void:
	softness = value
	_update_pin_joint()

func _on_bias_changed(value: float) -> void:
	bias = value
	_update_pin_joint()

func _on_collision_changed(button_pressed: bool) -> void:
	disable_collision = button_pressed
	_update_pin_joint()

func _update_pin_joint() -> void:
	if pin_joint:
		pin_joint.softness = softness
		pin_joint.bias = bias
		pin_joint.disable_collision = disable_collision

func _update_info() -> void:
	if info:
		info.text = "PinJoint2D 测试\n软度: %.2f | 偏差: %.2f\n碰撞: %s | 距离: %.1f" % [
			softness,
			bias,
			"禁用" if disable_collision else "启用",
			body_a.global_position.distance_to(body_b.global_position) if body_a and body_b else 0.0
		]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				# 重置关节参数
				softness = 0.0
				bias = 0.2
				disable_collision = false
				_update_ui_from_values()
				_update_pin_joint()
			KEY_2:
				# 软关节设置
				softness = 0.8
				bias = 0.1
				_update_ui_from_values()
				_update_pin_joint()
			KEY_3:
				# 硬关节设置
				softness = 0.0
				bias = 0.5
				_update_ui_from_values()
				_update_pin_joint()
			KEY_4:
				# 切换碰撞
				disable_collision = !disable_collision
				if collision_checkbox:
					collision_checkbox.button_pressed = disable_collision
				_update_pin_joint()
			KEY_R:
				# 重置物体位置
				if body_a:
					body_a.global_position = Vector2(400, 300)
					body_a.linear_velocity = Vector2.ZERO
					body_a.angular_velocity = 0.0
				if body_b:
					body_b.global_position = Vector2(600, 300)
					body_b.linear_velocity = Vector2.ZERO
					body_b.angular_velocity = 0.0

func _update_ui_from_values() -> void:
	if softness_slider:
		softness_slider.value = softness
	if bias_slider:
		bias_slider.value = bias
	if collision_checkbox:
		collision_checkbox.button_pressed = disable_collision
