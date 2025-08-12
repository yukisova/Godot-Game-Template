extends ReactorExtension

## 游戏的装备等游戏内信息相关的设置菜单
@export var brain_ui: PackedScene
@export var inventory: InventoryExtension

## 游戏的设置，游戏的退出等游戏外相关的设置菜单
@export var pause_ui: PackedScene

func _listen():
	if c_input_reactor.validate_control("brain_trigger", c_input_reactor.ControlMode.just_pressed):
		SUiSpawner._spawn_ui(brain_ui, {"inventory" : inventory})
	elif c_input_reactor.validate_control("pause_game", c_input_reactor.ControlMode.just_pressed):
		SUiSpawner._spawn_ui(pause_ui)
