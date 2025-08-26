## GrooveJoint2D 测试场景脚本
## 演示 GrooveJoint2D 槽关节的用法
extends Node2D

@export var groove_a: Vector2 = Vector2(-50, 0) ## 槽起点
@export var groove_b: Vector2 = Vector2(50, 0) ## 槽终点
@export var anchor: Vector2 = Vector2(0, 0) ## 锚点
@export var softness: float = 0.0 ## 关节软度
@export var bias: float = 0.2 ## 关节偏差
@export var max_force: float = 1000.0 ## 最大力
@export var disable_collision: bool = false ## 是否禁用碰撞

@onready var groove_joint: GrooveJoint2D = $GrooveJoint2D
@onready var body_a: RigidBody2D = $BodyA
@onready var body_b: RigidBody2D = $BodyB
@onready var info: Label = $CanvasLayer/Info
@onready var groove_a_x_slider: HSlider = $CanvasLayer/UI/GrooveAXSlider
@onready var groove_a_y_slider: HSlider = $CanvasLayer/UI/GrooveAYSlider
@onready var groove_b_x_slider: HSlider = $CanvasLayer/UI/GrooveBXSlider
@onready var groove_b_y_slider: HSlider = $CanvasLayer/UI/GrooveBYSlider
@onready var anchor_x_slider: HSlider = $CanvasLayer/UI/AnchorXSlider
@onready var anchor_y_slider: HSlider = $CanvasLayer/UI/AnchorYSlider
@onready var softness_slider: HSlider = $CanvasLayer/UI/SoftnessSlider
@onready var bias_slider: HSlider = $CanvasLayer/UI/BiasSlider
@onready var max_force_slider: HSlider = $CanvasLayer/UI/MaxForceSlider
@onready var collision_checkbox: CheckBox = $CanvasLayer/UI/CollisionCheckbox

func _ready() -> void:
	_setup_ui()
	_update_groove_joint()
	_update_info()

func _process(_delta: float) -> void:
	_update_info()

func _setup_ui() -> void:
	# 检查 UI 控件是否存在
	if groove_a_x_slider:
		groove_a_x_slider.min_value = -100.0
		groove_a_x_slider.max_value = 100.0
		groove_a_x_slider.value = groove_a.x
		groove_a_x_slider.value_changed.connect(_on_groove_a_x_changed)
	
	if groove_a_y_slider:
		groove_a_y_slider.min_value = -100.0
		groove_a_y_slider.max_value = 100.0
		groove_a_y_slider.value = groove_a.y
		groove_a_y_slider.value_changed.connect(_on_groove_a_y_changed)
	
	if groove_b_x_slider:
		groove_b_x_slider.min_value = -100.0
		groove_b_x_slider.max_value = 100.0
		groove_b_x_slider.value = groove_b.x
		groove_b_x_slider.value_changed.connect(_on_groove_b_x_changed)
	
	if groove_b_y_slider:
		groove_b_y_slider.min_value = -100.0
		groove_b_y_slider.max_value = 100.0
		groove_b_y_slider.value = groove_b.y
		groove_b_y_slider.value_changed.connect(_on_groove_b_y_changed)
	
	if anchor_x_slider:
		anchor_x_slider.min_value = -100.0
		anchor_x_slider.max_value = 100.0
		anchor_x_slider.value = anchor.x
		anchor_x_slider.value_changed.connect(_on_anchor_x_changed)
	
	if anchor_y_slider:
		anchor_y_slider.min_value = -100.0
		anchor_y_slider.max_value = 100.0
		anchor_y_slider.value = anchor.y
		anchor_y_slider.value_changed.connect(_on_anchor_y_changed)
	
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
	
	if max_force_slider:
		max_force_slider.min_value = 0.0
		max_force_slider.max_value = 5000.0
		max_force_slider.value = max_force
		max_force_slider.value_changed.connect(_on_max_force_changed)
	
	if collision_checkbox:
		collision_checkbox.button_pressed = disable_collision
		collision_checkbox.toggled.connect(_on_collision_changed)

func _on_groove_a_x_changed(value: float) -> void:
	groove_a.x = value
	_update_groove_joint()

func _on_groove_a_y_changed(value: float) -> void:
	groove_a.y = value
	_update_groove_joint()

func _on_groove_b_x_changed(value: float) -> void:
	groove_b.x = value
	_update_groove_joint()

func _on_groove_b_y_changed(value: float) -> void:
	groove_b.y = value
	_update_groove_joint()

func _on_anchor_x_changed(value: float) -> void:
	anchor.x = value
	_update_groove_joint()

func _on_anchor_y_changed(value: float) -> void:
	anchor.y = value
	_update_groove_joint()

func _on_softness_changed(value: float) -> void:
	softness = value
	_update_groove_joint()

func _on_bias_changed(value: float) -> void:
	bias = value
	_update_groove_joint()

func _on_max_force_changed(value: float) -> void:
	max_force = value
	_update_groove_joint()

func _on_collision_changed(button_pressed: bool) -> void:
	disable_collision = button_pressed
	_update_groove_joint()

func _update_groove_joint() -> void:
	if groove_joint:
		groove_joint.groove_a = groove_a
		groove_joint.groove_b = groove_b
		groove_joint.anchor = anchor
		groove_joint.softness = softness
		groove_joint.bias = bias
		groove_joint.max_force = max_force
		groove_joint.disable_collision = disable_collision

func _update_info() -> void:
	if info:
		var groove_length = groove_a.distance_to(groove_b)
		var anchor_distance = anchor.length()
		info.text = "GrooveJoint2D 测试\n槽起点: (%.1f, %.1f) | 槽终点: (%.1f, %.1f)\n锚点: (%.1f, %.1f) | 槽长度: %.1f | 锚距离: %.1f\n软度: %.2f | 偏差: %.2f | 最大力: %.1f | 碰撞: %s" % [
			groove_a.x, groove_a.y,
			groove_b.x, groove_b.y,
			anchor.x, anchor.y,
			groove_length,
			anchor_distance,
			softness,
			bias,
			max_force,
			"禁用" if disable_collision else "启用"
		]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				# 重置槽关节参数
				groove_a = Vector2(-50, 0)
				groove_b = Vector2(50, 0)
				anchor = Vector2(0, 0)
				softness = 0.0
				bias = 0.2
				max_force = 1000.0
				disable_collision = false
				_update_ui_from_values()
				_update_groove_joint()
			KEY_2:
				# 水平槽
				groove_a = Vector2(-80, 0)
				groove_b = Vector2(80, 0)
				anchor = Vector2(0, 50)
				_update_ui_from_values()
				_update_groove_joint()
			KEY_3:
				# 垂直槽
				groove_a = Vector2(0, -60)
				groove_b = Vector2(0, 60)
				anchor = Vector2(50, 0)
				_update_ui_from_values()
				_update_groove_joint()
			KEY_4:
				# 对角线槽
				groove_a = Vector2(-60, -60)
				groove_b = Vector2(60, 60)
				anchor = Vector2(0, 0)
				_update_ui_from_values()
				_update_groove_joint()
			KEY_5:
				# 弧形槽
				groove_a = Vector2(-40, -40)
				groove_b = Vector2(40, -40)
				anchor = Vector2(0, 60)
				_update_ui_from_values()
				_update_groove_joint()
			KEY_6:
				# 切换碰撞
				disable_collision = !disable_collision
				if collision_checkbox:
					collision_checkbox.button_pressed = disable_collision
				_update_groove_joint()
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
	if groove_a_x_slider:
		groove_a_x_slider.value = groove_a.x
	if groove_a_y_slider:
		groove_a_y_slider.value = groove_a.y
	if groove_b_x_slider:
		groove_b_x_slider.value = groove_b.x
	if groove_b_y_slider:
		groove_b_y_slider.value = groove_b.y
	if anchor_x_slider:
		anchor_x_slider.value = anchor.x
	if anchor_y_slider:
		anchor_y_slider.value = anchor.y
	if softness_slider:
		softness_slider.value = softness
	if bias_slider:
		bias_slider.value = bias
	if max_force_slider:
		max_force_slider.value = max_force
	if collision_checkbox:
		collision_checkbox.button_pressed = disable_collision
