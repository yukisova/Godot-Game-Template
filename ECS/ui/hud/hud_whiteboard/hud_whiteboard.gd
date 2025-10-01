## hud_whiteboard.gd
## 白板HUD - 提供游戏内一些会根据玩家当前状态显示的信息，如根据玩家当前所装备的道具（表）在右上角显示，与提示怪物方向的指南针
class_name HudWhiteboard
extends UIHudController

func _initialize():
	pass

func _refresh():
	pass

func clear():
	ui_view.clear()

## 添加因子
func add_factor(target: Control, _position: int ):
	pass

## 移除因子
func remove_factor(target: Control):
	pass
