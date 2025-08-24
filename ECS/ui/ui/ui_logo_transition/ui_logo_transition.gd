## Logo过渡场景 - 游戏启动时的品牌展示和过渡动画
## 该场景负责游戏启动时的Logo展示流程：多个Logo的顺序淡入淡出动画、可跳过的等待机制、平滑的场景切换过渡、专业的品牌展示效果
## 主要功能：自动播放Logo动画序列、用户输入跳过功能、定制化的动画时长、无缝的场景转换
## 使用场景：游戏首次启动、品牌标识展示、加载时间的优雅过渡、专业游戏的开场体验
## 动画特性：支持多个Logo的连续播放、可配置的淡入淡出时长、平滑的三次贝塞尔曲线过渡、黑色背景的专业视觉效果
## @editing: Sora
extends IUi

#region 动画配置

## 淡入淡出持续时间
## 每个Logo的淡入和淡出动画时长（秒）
@export var fade_duration: float = 0.5

## 停留持续时间
## 每个Logo完全显示时的停留时长（秒）
@export var stay_duration: float = 1

## 显示Logo列表
## 按顺序播放的Logo控件数组
@export var display_logos: Array[Control]

## 真实启动器场景
## Logo动画完成后要切换到的主启动器场景
@export var real_launcher: PackedScene

## 是否可跳过
## 用户是否可以通过输入跳过Logo动画
@export var interuptable: bool = true

#endregion

#region 场景生命周期

## 进入场景树时初始化—设置渲染环境和Logo初始状态
func _enter_tree() -> void:
	print("Logo过渡: 开始初始化")
	
	# 设置黑色背景
	
	# 将所有Logo设置为透明
	for i in display_logos:
		i.modulate.a = 0.0
	
	print("Logo过渡: 初始化完成，准备播放动画")

## 场景准备就绪时开始动画—创建并执行Logo的顺序播放动画
func _ready():
	print("Logo过渡: 开始播放Logo动画序列")
	
	# 创建动画补间
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	
	# 第一个Logo的淡入动画
	tween.tween_property(display_logos[0], "modulate:a", 1.0, fade_duration)\
		.from(0.0)
	
	# 第一个Logo的淡出动画
	tween.tween_property(display_logos[0], "modulate:a", 0.0, fade_duration)\
		.set_delay(stay_duration)
	
	# 第二个Logo的淡入动画
	tween.tween_property(display_logos[1], "modulate:a", 1.0, fade_duration)\
		.from(0.0)
	
	# 第二个Logo的淡出动画，完成后切换场景
	tween.tween_property(display_logos[1], "modulate:a", 0.0, fade_duration)\
		.set_delay(stay_duration)\
		.finished.connect(_change_scene)

#endregion

#region 输入处理

## 处理每帧输入—检查跳过输入
## [param _delta]: 帧时间间隔
func _process(_delta):
	# 检查跳过输入
	if interuptable and Input.is_action_just_pressed("ui_accept"):
		print("Logo过渡: 用户跳过动画")
		_change_scene()

#endregion

#region 场景切换

## 切换到启动器场景—结束Logo展示，进入主启动器
func _change_scene():
	print("Logo过渡: 切换到主启动器")
	get_tree().change_scene_to_packed(real_launcher)

#endregion
