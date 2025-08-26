## CanvasModulate 测试场景脚本
## 演示 CanvasModulate 的颜色调制和动画效果
extends Node2D

@export var modulate_color: Color = Color.WHITE ## 调制颜色
@export var modulate_enabled: bool = true ## 是否启用调制

@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var info: Label = $Info
@onready var color_picker: ColorPickerButton = $UI/ColorPicker
@onready var enabled_checkbox: CheckBox = $UI/EnabledCheckbox

func _ready() -> void:
	_setup_ui()
	_update_canvas_modulate()
	_update_info()

func _process(_delta: float) -> void:
	_update_info()

func _setup_ui() -> void:
	# 设置颜色选择器
	color_picker.color = modulate_color
	color_picker.color_changed.connect(_on_color_changed)
	
	# 设置启用复选框
	enabled_checkbox.button_pressed = modulate_enabled
	enabled_checkbox.toggled.connect(_on_enabled_changed)

func _on_color_changed(color: Color) -> void:
	modulate_color = color
	_update_canvas_modulate()

func _on_enabled_changed(button_pressed: bool) -> void:
	modulate_enabled = button_pressed
	_update_canvas_modulate()

func _update_canvas_modulate() -> void:
	canvas_modulate.color = modulate_color
	canvas_modulate.visible = modulate_enabled

func _update_info() -> void:
	info.text = "CanvasModulate 测试\n颜色: %s | 启用: %s\nRGB: (%.2f, %.2f, %.2f) | Alpha: %.2f" % [
		modulate_color.to_html(),
		"开启" if modulate_enabled else "关闭",
		modulate_color.r,
		modulate_color.g,
		modulate_color.b,
		modulate_color.a
	]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				# 红色调制
				_animate_color(Color.RED, 1.0)
			KEY_2:
				# 绿色调制
				_animate_color(Color.GREEN, 1.0)
			KEY_3:
				# 蓝色调制
				_animate_color(Color.BLUE, 1.0)
			KEY_4:
				# 黄色调制
				_animate_color(Color.YELLOW, 1.0)
			KEY_5:
				# 紫色调制
				_animate_color(Color.PURPLE, 1.0)
			KEY_6:
				# 青色调制
				_animate_color(Color.CYAN, 1.0)
			KEY_7:
				# 白色调制
				_animate_color(Color.WHITE, 1.0)
			KEY_8:
				# 黑色调制
				_animate_color(Color.BLACK, 1.0)
			KEY_9:
				# 彩虹循环效果
				_animate_rainbow()
			KEY_0:
				# 闪烁效果
				_animate_blink()

func _animate_color(target_color: Color, duration: float) -> void:
	var tween = create_tween()
	tween.tween_method(_set_color, modulate_color, target_color, duration)
	tween.tween_callback(func(): color_picker.color = modulate_color)

func _set_color(color: Color) -> void:
	modulate_color = color
	color_picker.color = color
	_update_canvas_modulate()

func _animate_rainbow() -> void:
	var colors = [Color.RED, Color.ORANGE, Color.YELLOW, Color.GREEN, Color.CYAN, Color.BLUE, Color.PURPLE]
	var tween = create_tween()
	tween.set_loops()
	
	for i in range(colors.size()):
		var next_color = colors[(i + 1) % colors.size()]
		tween.tween_method(_set_color, colors[i], next_color, 0.5)

func _animate_blink() -> void:
	var tween = create_tween()
	tween.set_loops(3)
	tween.tween_method(_set_color, modulate_color, Color.WHITE, 0.2)
	tween.tween_method(_set_color, Color.WHITE, modulate_color, 0.2)
	tween.tween_callback(func(): color_picker.color = modulate_color)
