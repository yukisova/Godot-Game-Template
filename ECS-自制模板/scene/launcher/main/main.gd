##@editing:	Sora
##@describe:	主进程场景
class_name Main
extends Node

signal system_register_completed

static var entity_initialzable: bool = false

static var game_view: Node
static var ui_view: Node

func _enter_tree() -> void:
	game_view = $GameView
	ui_view = $UiView

func _ready() -> void:
	system_register_completed.connect(_main_loop_start)
	register_system.call_deferred()

## 游戏系统解析
func register_system():
	SAudioMaster._setup()
	SGameState._setup()
	SGlobalConfig._setup()
	SLoadAndSave._setup()
	SMapData._setup()
	SPlayerStatic._setup()
	SSignalBus._setup()
	SUiSpawner._setup()

	system_register_completed.emit()

## 游戏主循环开始: 在其中自定义一堆的信息
func _main_loop_start():
	if Launcher.mode_setted == 1:
		SUiSpawner._loading_start_ui()

## 游戏设置数据解析
func _game_setting_parser(_setting_info: Dictionary):
	pass
