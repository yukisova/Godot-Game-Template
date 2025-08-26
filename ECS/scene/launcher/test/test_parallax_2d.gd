## Parallax2D 测试场景脚本
## 演示 Parallax2D 的视差滚动效果和相机跟随
extends Node2D

@export var camera_speed: float = 100.0 ## 相机移动速度
@export var auto_scroll: bool = true ## 是否自动滚动
@export var scroll_direction: Vector2 = Vector2(1, 0) ## 滚动方向

@onready var parallax: ParallaxBackground = $ParallaxBackground
@onready var camera: Camera2D = $Camera2D
@onready var info: Label = $CanvasLayer/Info
@onready var speed_slider: HSlider = $CanvasLayer/UI/SpeedSlider
@onready var auto_checkbox: CheckBox = $CanvasLayer/UI/AutoCheckbox
@onready var direction_x_slider: HSlider = $CanvasLayer/UI/DirectionXSlider
@onready var direction_y_slider: HSlider = $CanvasLayer/UI/DirectionYSlider

var _camera_position: Vector2 = Vector2.ZERO
var _time: float = 0.0

func _ready() -> void:
	_setup_ui()
	_update_info()

func _process(delta: float) -> void:
	_time += delta
	
	if auto_scroll:
		_camera_position += scroll_direction * camera_speed * delta
		camera.position = _camera_position
	
	_update_info()

func _setup_ui() -> void:
	# 检查 UI 控件是否存在
	if speed_slider:
		# 设置速度滑块
		speed_slider.min_value = 0.0
		speed_slider.max_value = 500.0
		speed_slider.value = camera_speed
		speed_slider.value_changed.connect(_on_speed_changed)
	
	if auto_checkbox:
		# 设置自动滚动复选框
		auto_checkbox.button_pressed = auto_scroll
		auto_checkbox.toggled.connect(_on_auto_changed)
	
	if direction_x_slider:
		# 设置方向滑块
		direction_x_slider.min_value = -1.0
		direction_x_slider.max_value = 1.0
		direction_x_slider.value = scroll_direction.x
		direction_x_slider.value_changed.connect(_on_direction_x_changed)
	
	if direction_y_slider:
		direction_y_slider.min_value = -1.0
		direction_y_slider.max_value = 1.0
		direction_y_slider.value = scroll_direction.y
		direction_y_slider.value_changed.connect(_on_direction_y_changed)

func _on_speed_changed(value: float) -> void:
	camera_speed = value

func _on_auto_changed(button_pressed: bool) -> void:
	auto_scroll = button_pressed

func _on_direction_x_changed(value: float) -> void:
	scroll_direction.x = value

func _on_direction_y_changed(value: float) -> void:
	scroll_direction.y = value

func _update_info() -> void:
	if info:
		info.text = "Parallax2D 测试\n相机位置: (%.1f, %.1f) | 速度: %.1f\n方向: (%.2f, %.2f) | 自动滚动: %s\n时间: %.1f" % [
			camera.position.x,
			camera.position.y,
			camera_speed,
			scroll_direction.x,
			scroll_direction.y,
			"开启" if auto_scroll else "关闭",
			_time
		]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				# 水平滚动
				scroll_direction = Vector2(1, 0)
				if direction_x_slider:
					direction_x_slider.value = 1.0
				if direction_y_slider:
					direction_y_slider.value = 0.0
			KEY_2:
				# 垂直滚动
				scroll_direction = Vector2(0, 1)
				if direction_x_slider:
					direction_x_slider.value = 0.0
				if direction_y_slider:
					direction_y_slider.value = 1.0
			KEY_3:
				# 对角线滚动
				scroll_direction = Vector2(1, 1).normalized()
				if direction_x_slider:
					direction_x_slider.value = scroll_direction.x
				if direction_y_slider:
					direction_y_slider.value = scroll_direction.y
			KEY_4:
				# 圆形滚动
				scroll_direction = Vector2(cos(_time), sin(_time))
				if direction_x_slider:
					direction_x_slider.value = scroll_direction.x
				if direction_y_slider:
					direction_y_slider.value = scroll_direction.y
			KEY_5:
				# 停止滚动
				scroll_direction = Vector2.ZERO
				if direction_x_slider:
					direction_x_slider.value = 0.0
				if direction_y_slider:
					direction_y_slider.value = 0.0
			KEY_SPACE:
				# 切换自动滚动
				auto_scroll = !auto_scroll
				if auto_checkbox:
					auto_checkbox.button_pressed = auto_scroll
			KEY_R:
				# 重置相机位置
				_camera_position = Vector2.ZERO
				camera.position = Vector2.ZERO
			KEY_UP:
				# 手动向上移动
				if !auto_scroll:
					_camera_position.y -= 50
					camera.position = _camera_position
			KEY_DOWN:
				# 手动向下移动
				if !auto_scroll:
					_camera_position.y += 50
					camera.position = _camera_position
			KEY_LEFT:
				# 手动向左移动
				if !auto_scroll:
					_camera_position.x -= 50
					camera.position = _camera_position
			KEY_RIGHT:
				# 手动向右移动
				if !auto_scroll:
					_camera_position.x += 50
					camera.position = _camera_position
