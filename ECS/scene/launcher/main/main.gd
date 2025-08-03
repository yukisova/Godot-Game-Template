## @editing: Sora [br]
## @describe: 主进程场景
class_name Main
extends Node

## 所有系统注册完成时发出
signal system_setup_completed

## 实体分为预定义实体, 系统加载时定义实体(目前只有[member SMainController.player_static]符合这一个条件) 
static var entity_initialzable: bool = false

## 游戏视图, 所有游戏内容放置于此
static var game_view: Node
## Ui视图, 所有Ui以及Hud放置于此
static var ui_view: Node

func _enter_tree() -> void:
	game_view = $GameView
	ui_view = $UiView

func _ready() -> void:
	system_setup_completed.connect(_main_loop_start)
	SSignalBus.ui_main_returned.connect(_on_system_reset_state)
	setup_system.call_deferred()

## 游戏系统注册
func setup_system():
	SSubSystemManager._setup()
	SSignalBus._setup()
	SGameState._setup()
	SGlobalConfig._setup()
	SLoadAndSave._setup()
	SMapData._setup()
	SMainController._setup()
	SUiSpawner._setup()
	SCommandParser._setup()
	SAudioMaster._setup()

	system_setup_completed.emit()

func _on_system_reset_state():
	SSubSystemManager._resetup()
	SSignalBus._resetup()
	SGameState._resetup()
	SGlobalConfig._resetup()
	SLoadAndSave._resetup()
	SMapData._resetup()
	SMainController._resetup()
	SUiSpawner._resetup()
	SCommandParser._resetup()
	SAudioMaster._resetup()
	
	system_setup_completed.emit()

## FIXME 忘记编写目的的方法 游戏主循环开始: 在其中自定义一堆的信息
func _main_loop_start():
	if Launcher.mode_setted == 1:
		SUiSpawner._loading_start_ui()

## 游戏设置数据解析
func _game_setting_parser(_setting_info: Dictionary):
	pass
