## 主场景，存放一些需要静态存储的变量
class_name Main
extends Node

signal system_register_completed

static var s_player_static: S_PlayerStatic
static var s_game_state: S_GameState
static var s_load_and_save: S_LoadAndSave
static var s_object_pool: ISystem
static var s_ui_spawner: S_UiSpawner
static var s_map_data: S_Mapdata
static var s_global_config: S_GlobalConfig
static var s_audio_master: S_AudioMaster

@export var game_view: Node
@export var ui_view: Node

func _ready() -> void:
	system_register_completed.connect(_main_loop_start)
	register_data.call_deferred()

func register_data():
	var systemContainer = $System
	for system in systemContainer.get_children():
		if (system is ISystem):
			system._setup()

	system_register_completed.emit()
	
## 游戏主循环开始: 在其中自定义一堆的信息
func _main_loop_start():
	s_ui_spawner.call("_loading_start_ui")

func _game_setting_parser(_setting_info: Dictionary):
	pass
