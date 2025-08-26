## CanvasGroup 测试场景脚本
## 演示 CanvasGroup 的透明度、可见性和混合模式功能
extends Node2D

@export var group_opacity: float = 1.0 ## 组透明度 (0.0-1.0)
@export var group_visible: bool = true ## 组可见性
# 注意：Godot 4.x 中 CanvasGroup 不支持直接的混合模式设置
# 混合效果需要通过 modulate 和自定义着色器实现
# CanvasGroup 在 Godot 4.x 中只支持基本的透明度、可见性和 modulate 控制

@onready var canvas_group: CanvasGroup = $CanvasGroup
@onready var info: Label = $Info
@onready var opacity_slider: HSlider = $UI/OpacitySlider
@onready var visible_checkbox: CheckBox = $UI/VisibleCheckbox
# 移除混合模式选项，因为 Godot 4.x 中 CanvasGroup 不支持直接的混合模式

func _ready() -> void:
	_setup_ui()
	_update_canvas_group()
	_update_info()

func _process(_delta: float) -> void:
	_update_info()

func _setup_ui() -> void:
	# 设置透明度滑块
	opacity_slider.min_value = 0.0
	opacity_slider.max_value = 1.0
	opacity_slider.value = group_opacity
	opacity_slider.value_changed.connect(_on_opacity_changed)
	
	# 设置可见性复选框
	visible_checkbox.button_pressed = group_visible
	visible_checkbox.toggled.connect(_on_visible_changed)

func _on_opacity_changed(value: float) -> void:
	group_opacity = value
	_update_canvas_group()

func _on_visible_changed(button_pressed: bool) -> void:
	group_visible = button_pressed
	_update_canvas_group()

func _update_canvas_group() -> void:
	canvas_group.modulate.a = group_opacity
	canvas_group.visible = group_visible

func _update_info() -> void:
	info.text = "CanvasGroup 测试\n透明度: %.2f | 可见性: %s\n子节点数量: %d" % [
		group_opacity,
		"开启" if group_visible else "关闭",
		canvas_group.get_child_count()
	]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				# 淡入效果
				_animate_opacity(0.0, 1.0, 1.0)
			KEY_2:
				# 淡出效果
				_animate_opacity(1.0, 0.0, 1.0)
			KEY_3:
				# 闪烁效果
				_animate_blink()
			KEY_4:
				# 切换可见性
				group_visible = !group_visible
				visible_checkbox.button_pressed = group_visible
				_update_canvas_group()

func _animate_opacity(from: float, to: float, duration: float) -> void:
	var tween = create_tween()
	tween.tween_method(_set_opacity, from, to, duration)
	tween.tween_callback(func(): opacity_slider.value = group_opacity)

func _set_opacity(value: float) -> void:
	group_opacity = value
	opacity_slider.value = value
	_update_canvas_group()

func _animate_blink() -> void:
	var tween = create_tween()
	tween.set_loops(3)
	tween.tween_method(_set_opacity, 1.0, 0.3, 0.2)
	tween.tween_method(_set_opacity, 0.3, 1.0, 0.2)
	tween.tween_callback(func(): opacity_slider.value = group_opacity)
