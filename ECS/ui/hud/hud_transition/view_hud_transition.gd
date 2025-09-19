extends UIView

## 纯黑色的遮罩
@export var pure_black_rect: ColorRect

## 淡入效果
## 
## 从黑屏逐渐显示游戏画面，使用标准1.5秒动画时长。
func fade_in():
	if not pure_black_rect:
		push_error("过渡HUD: pure_black_rect未设置")
		return
	
	print("过渡HUD: 开始淡入效果")
	var tween = get_tree().create_tween()
	tween.tween_property(pure_black_rect, "modulate", Color(0, 0, 0, 0), 1.5)
	await tween.finished
	print("过渡HUD: 淡入效果完成")

## 淡出效果
## 
## 游戏画面逐渐变为黑屏，使用标准1.5秒动画时长。
func fade_out():
	if not pure_black_rect:
		push_error("过渡HUD: pure_black_rect未设置") 
		return
	
	print("过渡HUD: 开始淡出效果")
	var tween = get_tree().create_tween()
	tween.tween_property(pure_black_rect, "modulate", Color(0, 0, 0, 1), 1.5)
	await tween.finished
	print("过渡HUD: 淡出效果完成")
#endregion
