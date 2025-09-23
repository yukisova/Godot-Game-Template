extends ISystem

@export var logo_transition_scene: PackedScene

@export var main_menu_scene: PackedScene

@export var cutscene_scene: PackedScene

@export var all_hud: Dictionary[StringName, HudInitSetting]

var current_hud: Dictionary[StringName, UIHudController] = {}

var current_ui: UIController

func _setup():
	# 预加载所有配置的HUD
	for key in all_hud:
		if all_hud[key].is_preload:
			var hud = all_hud[key].hud_scene.instantiate()
			Main.ui_view.add_child(hud)
			current_hud[key] = hud as UIHudController
			current_hud[key].hide()  # 初始状态隐藏
	
	SSignalBus.game_loop_start.connect(func():
		for hud: UIHudController in current_hud.values():
			hud._initialize()
		_hide_all_hud([""])
	)
	
	SSignalBus.game_loop_continue.connect(func():
		_hide_all_hud([""])
	)
	
	SSignalBus.game_loop_paused.connect(func():
		_hide_all_hud([])
	)

func _resetup():
	_hide_all_hud([])

func _spawn_ui(scene: PackedScene, context: Dictionary = {}, is_main_or_cutscene: bool = false) -> UIController:
	if scene == null:
		push_warning("UI生成器: 尝试生成空的UI场景")
		return null
	
	# 实例化UI场景
	var canvas = scene.instantiate()
	if canvas is UIController:
		# 清理现有UI（单例模式）
		if current_ui:
			current_ui.queue_free()
		
		var current_game_state = SGameState.state_machine.get_leaf_state()
		if current_game_state is GamingStateNormal:
			current_game_state.game_paused.emit()
		elif !is_main_or_cutscene:
			return
		# 设置新UI
		current_ui = canvas
		canvas._initilize_info(context)
		Main.ui_view.add_child(current_ui)
		current_ui._unspawned.connect(_unspawn_ui)
		
		print("UI生成器: 成功生成UI -> ", scene.resource_path.get_file())
		return canvas
	else:
		# 不是有效的UI，清理并返回null
		canvas.queue_free()
		push_error("UI生成器: 场景不是有效的IUi类型 -> ", scene.resource_path)
		return null

func _hide_all_hud(except_hud_name: Array):
	for hud_name in current_hud.keys():
		if except_hud_name.has(hud_name):
			current_hud[hud_name].try_show()
		else:
			current_hud[hud_name].try_hide()

func _hide_hud(hud_name: StringName):
	if current_hud.has(hud_name):
		current_hud[hud_name].try_hide()
	else:
		push_warning("UI生成器: 未找到HUD -> ", hud_name)


func _unspawn_ui(target_ui: UIController):
	if target_ui == current_ui:
		target_ui.queue_free()
		current_ui = null
		
		var current_game_state = SGameState.state_machine.get_leaf_state()
		if current_game_state is GamingStatePause:
			current_game_state.game_retry.emit()
		
		print("UI生成器: UI已销毁，游戏状态恢复")

func _all_unspawn():
	for ui_node in Main.ui_view.get_children():
		ui_node.queue_free()
	current_ui = null
	print("UI生成器: 所有UI已清理")

func _loading_start_ui():
	_spawn_ui(main_menu_scene, {}, true)	

func _loading_start_cutscene():
	_spawn_ui(cutscene_scene, {}, true)

func _loading_start_logo_transition():
	_spawn_ui(logo_transition_scene, {}, true)

func _get_hud(keyword: StringName):
	return current_hud.get(keyword)
