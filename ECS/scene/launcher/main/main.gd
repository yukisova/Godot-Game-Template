## 主进程管理器 - 游戏系统的核心启动和协调中心
##
## 该类负责管理整个游戏的启动流程、系统初始化和生命周期管理。
## 作为所有游戏系统的协调者，确保系统按正确的顺序启动和关闭。
##
## 核心职责：
## - 系统启动顺序管理
## - 系统状态重置
## - 全局视图管理
## - 实体初始化控制
## - 物理和导航层级定义
##
## 系统启动顺序：
## 1. [SBlackboard] - 全局数据共享
## 2. [SSignalBus] - 事件通信
## 3. [SGameState] - 游戏状态
## 4. [SGlobalConfig] - 全局配置
## 5. [SLoadAndSave] - 存档系统
## 6. [SMapData] - 地图数据
## 7. [SMainController] - 主控制器
## 8. [SUiSpawner] - UI管理
## 9. [SCommandParser] - 命令解析
## 10. [SAudioMaster] - 音频系统
##
## 架构设计：
## - 继承自 [Node] 基类
## - 基于 [signal system_setup_completed] 的系统协调
## - 通过静态变量提供全局访问
## - 与 [Launcher] 系统集成
##
## [br][b]编辑者:[/b] Sora
class_name Main
extends Node

## 系统注册完成信号
## 
## 当所有游戏系统初始化完成后发出。
signal system_setup_completed

## 实体初始化状态标志
## 
## 控制实体的创建时机，true表示可以创建实体。
## 实体分为预定义实体和系统加载时定义实体（如玩家静态实体）。
static var entity_initialzable: bool = false

## 游戏视图容器
## 
## 所有游戏内容（地图、实体、特效等）都放置在此节点下，类型为 [Node]。
static var game_view: Node

## UI视图容器
## 
## 所有UI界面和HUD元素都放置在此节点下，类型为 [Node]。
static var ui_view: Node

## 节点初始化
## 设置游戏和UI视图的引用
func _enter_tree() -> void:
	game_view = $GameView
	ui_view = $UiView

## 主进程准备
## 连接系统事件并启动系统初始化流程
func _ready() -> void:
	system_setup_completed.connect(_main_loop_start)
	SSignalBus.ui_main_returned.connect(_on_system_reset_state)
	
	# 延迟执行系统设置，确保场景完全加载
	setup_system.call_deferred()

## 游戏系统注册和初始化
## 按照依赖关系的正确顺序初始化所有游戏系统
func setup_system():
	print("主进程: 开始初始化游戏系统...")
	
	# 按依赖顺序初始化系统
	SBlackboard._setup()      # 全局数据共享基础
	SSignalBus._setup()       # 事件通信基础
	SGameState._setup()       # 游戏状态管理
	SGlobalConfig._setup()    # 全局配置管理
	SLoadAndSave._setup()     # 存档系统
	SMapData._setup()         # 地图数据管理
	SMainController._setup()  # 主控制器
	SUiSpawner._setup()       # UI管理器
	SCommandParser._setup()   # 命令解析器
	SAudioMaster._setup()     # 音频管理器

	print("主进程: 系统初始化完成")
	system_setup_completed.emit()

## 系统状态重置
## 当返回主菜单时重置所有系统状态，准备新的游戏会话
func _on_system_reset_state():
	print("主进程: 开始重置系统状态...")
	
	# 按相同顺序重置所有系统
	SBlackboard._resetup()
	SSignalBus._resetup()
	SGameState._resetup()
	SGlobalConfig._resetup()
	SLoadAndSave._resetup()
	SMapData._resetup()
	SMainController._resetup()
	SUiSpawner._resetup()
	SCommandParser._resetup()
	SAudioMaster._resetup()
	
	print("主进程: 系统重置完成")
	# 注意：重置时不触发system_setup_completed信号，避免循环引用
	system_setup_completed.emit()

## 游戏主循环开始
## 系统初始化完成后的启动逻辑，根据启动模式执行不同的流程
## TODO: 需要明确此方法的具体用途和完善实现
func _main_loop_start():
	print("主进程: 游戏主循环开始")
	
	# 实体现在可以被创建
	entity_initialzable = true
	
	# 根据启动模式执行相应逻辑
	if Launcher.mode_setted == 1:
		# 正常游戏模式：显示开始UI
		SUiSpawner._loading_start_ui()

## 游戏设置数据解析
## 
## 处理游戏设置相关的配置数据。
## [param _setting_info]: 设置信息字典，类型为 [Dictionary]
## TODO: 实现具体的设置解析逻辑
func _game_setting_parser(_setting_info: Dictionary):
	# 待实现：解析和应用游戏设置
	pass

## 物理层级枚举
## 
## 定义游戏中不同类型碰撞体的物理层级，用于碰撞检测的精确控制。
enum PhysicsLayer {
	Wall = 1 << 0,         ## 墙壁和固体障碍物的碰撞层
	Interactable = 1 << 1, ## 可交互对象的碰撞层
	Breakable = 1 << 2,    ## 可破坏对象的碰撞层
}

## 导航层级枚举
## 
## 定义AI导航系统中的不同导航层级，用于路径规划和区域限制。
enum NavigationLayer {
	Normal = 1 << 0, ## 标准导航层，基于地图的 [TileMapLayer] 层生成
	Zone = 1 << 1,   ## 特殊区域导航层，用于随机移动区域，基于 [NavigationPolygon]
}
