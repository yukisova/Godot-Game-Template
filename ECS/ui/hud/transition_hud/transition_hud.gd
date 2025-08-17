## 过渡HUD - 处理场景切换和过渡效果的专业化界面系统
##
## 该HUD系统专门用于管理游戏中的各种过渡效果，提供流畅的视觉体验。
## 支持多种过渡效果和自定义动画，确保场景切换的专业化表现。
##
## 核心功能：
## - 高质量的淡入淡出动画
## - 灵活的过渡时长控制
## - 异步操作的完整支持
## - 多样化的过渡样式选择
## - 错误处理和状态验证
##
## 过渡效果类型：
## - [b]标准过渡[/b]：场景切换时的淡入淡出（1.5秒）
## - [b]快速过渡[/b]：短时间的快速切换（0.5秒默认）
## - [b]自定义时长[/b]：可配置的动画持续时间
## - [b]黑屏遮罩[/b]：基于ColorRect的高效遮罩系统
##
## 使用场景：
## - 关卡之间的无缝切换
## - 游戏开始和结束的专业表现
## - 剧情片段的流畅衔接
## - 菜单界面的优雅转换
## - 死亡重生的视觉效果
## - 加载画面的显示控制
##
## 技术特性：
## - 基于Tween系统的高性能动画
## - 异步await模式的精确控制
## - 完整的错误处理机制
## - 模块化的过渡效果组合
## - 初始状态的自动管理
##
## 架构设计：
## - 继承自 [IHud] 基类
## - 基于 [ColorRect] 的遮罩实现
## - 使用 [Tween] 系统的动画控制
## - 支持异步操作的现代设计模式
##
## [br][b]编辑者:[/b] Sora
extends IHud

#region UI组件

## 黑色矩形遮罩
## 
## 用于实现淡入淡出效果的主要UI元素，类型为 [ColorRect]。
## 通过调整其透明度来创建各种过渡效果。
@export var black_rect: ColorRect

#endregion

#region HUD生命周期

## HUD初始化（重写方法）
## 
## 设置过渡效果的初始状态，确保遮罩处于透明状态。
func _initialize():
	print("过渡HUD: 初始化完成")
	# 确保初始状态为透明（不遮挡画面）
	if black_rect:
		black_rect.modulate = Color(0, 0, 0, 0)

## HUD刷新（重写方法）
## 
## 更新过渡状态，当前为预留接口。
func _refresh():
	pass

#endregion

#region 过渡效果

## 淡入效果
## 
## 从黑屏逐渐显示游戏画面，使用标准1.5秒动画时长。
func fade_in():
	if not black_rect:
		push_error("过渡HUD: black_rect未设置")
		return
	
	print("过渡HUD: 开始淡入效果")
	var tween = get_tree().create_tween()
	tween.tween_property(black_rect, "modulate", Color(0, 0, 0, 0), 1.5)
	await tween.finished
	print("过渡HUD: 淡入效果完成")

## 淡出效果
## 
## 游戏画面逐渐变为黑屏，使用标准1.5秒动画时长。
func fade_out():
	if not black_rect:
		push_error("过渡HUD: black_rect未设置") 
		return
	
	print("过渡HUD: 开始淡出效果")
	var tween = get_tree().create_tween()
	tween.tween_property(black_rect, "modulate", Color(0, 0, 0, 1), 1.5)
	await tween.finished
	print("过渡HUD: 淡出效果完成")

## 快速淡入
## 
## 更短时间的淡入效果，适用于快速场景切换。
## [param duration]: 动画持续时间，默认0.5秒，类型为 [float]
func quick_fade_in(duration: float = 0.5):
	if not black_rect:
		return
	
	var tween = get_tree().create_tween()
	tween.tween_property(black_rect, "modulate", Color(0, 0, 0, 0), duration)
	await tween.finished

## 快速淡出
## 
## 更短时间的淡出效果，适用于快速场景切换。
## [param duration]: 动画持续时间，默认0.5秒，类型为 [float]
func quick_fade_out(duration: float = 0.5):
	if not black_rect:
		return
	
	var tween = get_tree().create_tween()
	tween.tween_property(black_rect, "modulate", Color(0, 0, 0, 1), duration)
	await tween.finished

#endregion
