## UI生成器系统 - 统一管理游戏中所有UI和HUD的生成、显示和生命周期
## 负责管理游戏中的用户界面，包括HUD和弹窗UI的创建、显示、隐藏和销毁
## 核心功能：HUD管理、UI生成、状态联动、内存管理、场景控制
## 应用场景：游戏HUD、菜单系统、对话界面、主菜单
## [br][b]编辑者:[/b] Sora
extends ISystem

## 主菜单场景，游戏启动时显示的主菜单界面场景
@export var logo_transition_scene: PackedScene

@export var main_menu_scene: PackedScene

## 开场剧情场景，游戏启动时显示的开场剧情界面场景，在结束之后进入主菜单
@export var cutscene_scene: PackedScene

## 所有HUD场景字典，预配置的所有HUD界面，键为HUD名称，值为对应的场景
@export var all_hud: Dictionary[StringName, HudInitSetting]

## 当前活跃的HUD实例字典，存储所有已实例化的HUD对象，用于统一管理
var current_hud: Dictionary[StringName, IHud] = {}

## 当前活跃的UI实例，指向当前显示的弹窗UI，采用单例模式
var current_ui: IUi

## 系统设置，预加载所有HUD并连接游戏状态信号
func _setup():
	# 预加载所有配置的HUD
	for key in all_hud:
		if all_hud[key].is_preload:
			var hud = all_hud[key].hud_scene.instantiate()
			Main.ui_view.add_child(hud)
			current_hud[key] = hud as IHud
			current_hud[key].hide()  # 初始状态隐藏
	
	# 连接游戏循环开始信号 - 初始化所有HUD
	SSignalBus.game_loop_start.connect(func():
		for hud: IHud in current_hud.values():
			hud._initialize()
		_hide_hud([""])
	)
	
	# 连接游戏循环继续信号 - 刷新所有HUD显示
	SSignalBus.game_loop_continue.connect(func():
		for hud: IHud in current_hud.values():
			hud._refresh()
		_hide_hud([""])
	)
	
	# 连接游戏循环暂停信号 - 隐藏所有HUD
	SSignalBus.game_loop_paused.connect(func():
		_hide_hud([])
	)

## 系统重置，隐藏所有HUD，准备重新开始
func _resetup():
	for hud in current_hud.values():
		hud.hide()

## 生成UI界面，创建新的弹窗UI，采用单例模式确保同时只有一个UI存在
## [param scene]: 要生成的UI场景，类型为 [PackedScene]
## [param context]: 传递给UI的初始化上下文数据
## [param is_main]: 传入的scene如果是主菜单性质的UI，则可以忽略状态机直接打开
## [br][br][b]返回:[/b] 生成的UI实例，失败则返回null
func _spawn_ui(scene: PackedScene, context: Dictionary = {}, is_main_or_cutscene: bool = false) -> IUi:
	if scene == null:
		push_warning("UI生成器: 尝试生成空的UI场景")
		return null
	
	# 实例化UI场景
	var canvas = scene.instantiate()
	if canvas is IUi:
		# 清理现有UI（单例模式）
		if current_ui:
			current_ui.queue_free()
		
		var current_game_state = SGameState.state_machine._get_leaf_state()
		if current_game_state is GamingStateNormal:
			current_game_state.game_paused.emit()
		elif !is_main_or_cutscene:
			return
		# 设置新UI
		current_ui = canvas
		canvas._initilize_info(context)
		Main.ui_view.add_child(current_ui)
		current_ui._unspawned.connect(_unspawn_ui)
		
		# 如果当前处于正常游戏状态，则自动暂停游戏
		
		
		print("UI生成器: 成功生成UI -> ", scene.resource_path.get_file())
		return canvas
	else:
		# 不是有效的UI，清理并返回null
		canvas.queue_free()
		push_error("UI生成器: 场景不是有效的IUi类型 -> ", scene.resource_path)
		return null

## 隐藏HUD（除了指定的例外），用于场景切换或特殊状态下的HUD管理
## [param except_hud_name]: 不需要隐藏的HUD名称数组
func _hide_hud(except_hud_name: Array):
	for hud_name in current_hud.keys():
		if except_hud_name.has(hud_name):
			# 例外HUD保持显示
			current_hud[hud_name].show()
		else:
			# 其他HUD隐藏
			current_hud[hud_name].hide()

## 销毁UI界面，处理UI的销毁请求，并恢复游戏状态
## [param target_ui]: 要销毁的UI实例，类型为 [IUi]
func _unspawn_ui(target_ui: IUi):
	if target_ui == current_ui:
		target_ui.queue_free()
		current_ui = null
		
		# 如果当前处于暂停状态，则自动恢复游戏
		var current_game_state = SGameState.state_machine._get_leaf_state()
		if current_game_state is GamingStatePause:
			current_game_state.game_retry.emit()
		
		print("UI生成器: UI已销毁，游戏状态恢复")

## 销毁所有UI，清理UI视图中的所有界面元素
func _all_unspawn():
	for ui_node in Main.ui_view.get_children():
		ui_node.queue_free()
	current_ui = null
	print("UI生成器: 所有UI已清理")

## 启动主菜单UI，当系统完成加载时显示主菜单界面
func _loading_start_ui():
	_spawn_ui(main_menu_scene, {}, true)	

func _loading_start_cutscene():
	_spawn_ui(cutscene_scene, {}, true)

func _loading_start_logo_transition():
	_spawn_ui(logo_transition_scene, {}, true)

## 获取指定HUD，根据关键词获取对应的HUD实例
## [param keyword]: HUD的标识名称，类型为 [StringName]
## [br][br][b]返回:[/b] 对应的HUD实例，不存在则返回null
func _get_hud(keyword: StringName):
	return current_hud.get(keyword)
