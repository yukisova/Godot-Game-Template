extends UIHudController

#region UI组件

## 黑色矩形遮罩
## 用于实现淡入淡出效果的主要UI元素，通过调整其透明度来创建各种过渡效果

#endregion

#region HUD生命周期

## HUD初始化（重写方法）
## 设置过渡效果的初始状态，确保遮罩处于透明状态。
func _initialize():
	fade_out()

## HUD刷新（重写方法）
## 更新过渡状态，当前为预留接口。
func _refresh():
	pass

func fade_in():
	ui_view.fade_in()

func fade_out():
	ui_view.fade_out()

#endregion
