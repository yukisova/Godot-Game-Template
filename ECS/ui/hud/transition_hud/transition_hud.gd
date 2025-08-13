## @editing: Sora [br]
## @describe: 过渡HUD - 处理场景切换和过渡效果
##
## 该HUD专门用于管理游戏中的各种过渡效果：
## - 场景切换时的淡入淡出
## - 加载画面的显示和隐藏
## - 剧情转场效果
## - 死亡重生的屏幕效果
##
## 主要功能：
## - 平滑的淡入淡出动画
## - 自定义过渡时长
## - 异步等待过渡完成
## - 支持不同的过渡样式
##
## 应用场景：
## - 关卡之间的切换
## - 游戏开始和结束
## - 剧情片段的衔接
## - 菜单界面转换
extends IHud

#region UI组件

## 黑色矩形遮罩
## 用于实现淡入淡出效果的主要元素
@export var black_rect: ColorRect

#endregion

#region HUD生命周期

## HUD初始化
## 设置过渡效果的初始状态
func _initialize():
	print("过渡HUD: 初始化完成")
	# 确保初始状态为透明（不遮挡画面）
	if black_rect:
		black_rect.modulate = Color(0, 0, 0, 0)

## HUD刷新
## 更新过渡状态（预留接口）
func _refresh():
	pass

#endregion

#region 过渡效果

## 淡入效果
## 从黑屏逐渐显示游戏画面
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
## 游戏画面逐渐变为黑屏
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
## 更短时间的淡入效果
func quick_fade_in(duration: float = 0.5):
	if not black_rect:
		return
	
	var tween = get_tree().create_tween()
	tween.tween_property(black_rect, "modulate", Color(0, 0, 0, 0), duration)
	await tween.finished

## 快速淡出
## 更短时间的淡出效果
func quick_fade_out(duration: float = 0.5):
	if not black_rect:
		return
	
	var tween = get_tree().create_tween()
	tween.tween_property(black_rect, "modulate", Color(0, 0, 0, 1), duration)
	await tween.finished

#endregion
