## @editing: Sora [br]
## @describe: UI生成器系统 - 统一管理游戏中所有UI和HUD的生成、显示和生命周期
## 
## 该系统负责管理游戏中的用户界面，包括HUD（抬头显示）和弹窗UI的创建、
## 显示、隐藏和销毁。与游戏状态系统紧密集成，根据游戏状态自动管理UI显示。
## 
## 核心功能：
## - HUD管理：预加载并管理所有HUD元素的生命周期
## - UI生成：动态创建和销毁弹窗类UI界面
## - 状态联动：根据游戏状态自动切换UI显示
## - 内存管理：确保UI资源的正确释放和回收
## - 场景控制：UI弹出时自动暂停游戏逻辑
## 
## HUD系统特性：
## - 预加载：系统启动时预先实例化所有HUD
## - 状态响应：根据游戏循环状态自动刷新显示
## - 选择性显示：支持只显示特定HUD，隐藏其他
## - 生命周期：完整的初始化、刷新、隐藏流程
## 
## UI弹窗特性：
## - 单例模式：同时只能有一个弹窗UI存在
## - 自动暂停：弹出UI时自动切换游戏到暂停状态
## - 上下文传递：支持向UI传递初始化上下文数据
## - 事件驱动：通过信号处理UI的关闭和清理
## 
## 应用场景：
## - 游戏HUD：血条、小地图、技能栏等常驻界面
## - 菜单系统：暂停菜单、设置界面、背包界面
## - 对话界面：NPC对话、剧情对话等临时界面
## - 主菜单：游戏开始时的主菜单界面
extends ISystem

## 主菜单场景
## 游戏启动时显示的主菜单界面场景
@export var main_menu_scene: PackedScene

## 所有HUD场景字典
## 预配置的所有HUD界面，键为HUD名称，值为对应的场景
@export var all_hud: Dictionary[StringName, PackedScene]

## 当前活跃的HUD实例字典
## 存储所有已实例化的HUD对象，用于统一管理
var current_hud: Dictionary[StringName, IHud] = {}

## 当前活跃的UI实例
## 指向当前显示的弹窗UI，采用单例模式
var current_ui: IUi

## 系统设置
## 预加载所有HUD并连接游戏状态信号
func _setup():
	# 预加载所有配置的HUD
	for key in all_hud:
		var hud = all_hud[key].instantiate()
		Main.ui_view.add_child(hud)
		current_hud[key] = hud as IHud
		current_hud[key].hide()  # 初始状态隐藏
	
	# 连接游戏循环开始信号 - 初始化所有HUD
	SSignalBus.game_loop_start.connect(func():
		for hud: IHud in current_hud.values():
			hud._initialize()
	)
	
	# 连接游戏循环继续信号 - 刷新所有HUD显示
	SSignalBus.game_loop_continue.connect(func():
		for hud: IHud in current_hud.values():
			hud._refresh()
	)
	
	# 连接游戏循环暂停信号 - 隐藏所有HUD
	SSignalBus.game_loop_paused.connect(func():
		for hud: IHud in current_hud.values():
			hud.hide()
	)

## 系统重置
## 隐藏所有HUD，准备重新开始
func _resetup():
	for hud in current_hud.values():
		hud.hide()

## 生成UI界面
## 创建新的弹窗UI，采用单例模式确保同时只有一个UI存在
## @param scene: 要生成的UI场景
## @param context: 传递给UI的初始化上下文数据
## @param is_main: 传入的scene如果是主菜单性质的UI，则可以忽略状态机直接打开
## @return: 生成的UI实例，失败则返回null
func _spawn_ui(scene: PackedScene, context: Dictionary = {}, is_main: bool = false) -> IUi:
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
		elif !is_main:
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

## 隐藏HUD（除了指定的例外）
## 用于场景切换或特殊状态下的HUD管理
## @param except_hud_name: 不需要隐藏的HUD名称数组
func _hide_hud(except_hud_name: Array):
	for hud_name in current_hud.keys():
		if except_hud_name.has(hud_name):
			# 例外HUD保持显示
			current_hud[hud_name].show()
		else:
			# 其他HUD隐藏
			current_hud[hud_name].hide()

## 销毁UI界面
## 处理UI的销毁请求，并恢复游戏状态
## @param target_ui: 要销毁的UI实例
func _unspawn_ui(target_ui: IUi):
	if target_ui == current_ui:
		target_ui.queue_free()
		current_ui = null
		
		# 如果当前处于暂停状态，则自动恢复游戏
		var current_game_state = SGameState.state_machine._get_leaf_state()
		if current_game_state is GamingStatePause:
			current_game_state.game_retry.emit()
		
		print("UI生成器: UI已销毁，游戏状态恢复")

## 销毁所有UI
## 清理UI视图中的所有界面元素
func _all_unspawn():
	for ui_node in Main.ui_view.get_children():
		ui_node.queue_free()
	current_ui = null
	print("UI生成器: 所有UI已清理")

## 启动主菜单UI
## 当系统完成加载时显示主菜单界面
func _loading_start_ui():
	_spawn_ui(main_menu_scene, {}, true)

## 获取指定HUD
## 根据关键词获取对应的HUD实例
## @param keyword: HUD的标识名称
## @return: 对应的HUD实例，不存在则返回null
func _get_hud(keyword: StringName):
	return current_hud.get(keyword)
