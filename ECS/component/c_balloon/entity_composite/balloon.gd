## 实体内Control的基类，为玩家进行提示
## [br][b]编辑者:[/b] Sora 
@abstract class_name Balloon
extends Control

func composite_appear():
	show()
	_fade_out()
	
func composite_disappear():
	_fade_in()
	hide()

## 控制 Control 消失的方法，应当使用Tween动画进行设计
@abstract func _fade_in()
## 控制 Control 显示的方法，应当使用Tween动画进行设计
@abstract func _fade_out()
