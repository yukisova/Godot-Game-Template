## 游戏主控制系统 - 管理玩家的输入信息逻辑与主要控制对象
##
## 该系统负责管理玩家角色的生成、定位、传送等核心功能。
## 是玩家实体与其他系统交互的中央控制器。
##
## 主要功能：
## - 玩家角色的实例化和生命周期管理
## - 玩家定位和传送逻辑
## - 伙伴角色的加入和管理
## - 玩家输入的方向控制算法
##
## 架构设计：
## - 基于信号的事件驱动系统
## - 支持多种移动模式（4向、8向、全向）
## - 与 [InputListener] 和 [SUiSpawner] 系统集成
##
## [br][b]编辑者:[/b] Sora
extends ISystem

## 玩家定位信号
## 
## 当玩家角色需要被定位到特定关卡时发出的信号。
## [param target_level]: 目标关卡，类型为 [Level]
## [param _context]: 定位上下文信息，包含类型和位置数据
signal player_located(target_level: Level, _context: Dictionary)

## 伙伴加入信号
## 
## 当新伙伴角色加入游戏时发出的信号。
## [param _partner]: 加入的伙伴实体，类型为 [IEntity]
signal partner_joined(_partner: IEntity)

## 玩家场景资源
## 
## 用于实例化玩家角色的预制场景。
@export var player_scene: PackedScene

@export_subgroup("依赖")

## 输入监听器
## 
## 处理玩家输入的组件，详见 [InputListener] 类。
@export var input_listener: InputListener

## 当前伙伴实体
## 
## 当前活跃的伙伴角色，类型为 [IEntity]。
@export var partner: IEntity = null

## 玩家静态实体
## 
## 持久化的玩家角色实体实例，类型为 [IEntity]。
var player_static: IEntity

func _setup():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	partner_joined.connect(func(_partner: IEntity):
		if partner:
			partner.queue_free()
		partner = _partner
	)
	player_located.connect(_on_player_located)

## 玩家定位处理回调
## 
## 处理玩家定位信号的回调函数，支持初始化和传送两种模式。
## [param target_level]: 目标关卡，类型为 [Level]
## [param _context]: 定位上下文信息，必须包含type字段
func _on_player_located(target_level: Level, _context: Dictionary):
	match _context.get("type", "Initialize"):
		"Initialize":
			if (player_static != null):
				player_static.reparent(target_level)
				player_static.global_position = _context["start_position"]
				player_static.main_control.global_position = _context["current_position"]
			else:
				var player_scene_path = _context.get("scene_file_path", null)
				if player_scene_path != null:
					player_scene = load(player_scene_path)
				player_static = player_scene.instantiate()
				player_static.global_position = _context["start_position"]
				player_static.main_control.global_position = _context["current_position"]
				target_level.add_child(player_static)
			
			target_level.entity_count += 1 ## 目标的target_level新加了玩家，因此要进行额外的判断
			
			player_static.initialize_complete.connect(func():
				target_level._on_entity_initialize()
				SUiSpawner.current_hud[&""].binding_entity = player_static
				SUiSpawner.current_hud[&""]._initialize()
			)
		"Transport":
			if (player_static != null):
				_context["target_level"].add_child(player_static)
				var target_point: TransportPoint = _context["target_point"]
				var start_position: Vector2 = target_point.global_position + target_point.tranported_offset
				player_static.global_position = start_position
				player_static.main_control.global_position = start_position
			else:
				push_error("传送时未检测到玩家，请检查玩家配置")
				return
		_:
			push_error("未知的玩家初始化信息类型: %s" % _context.get("type", "Initialize"))
	
	SSignalBus.entity_initialize_started.emit()

#region 角色的主要移动方法(工具方法)

## 双向移动输入（未实现）
## 
## 预留的双向移动控制方法。
## [br][br][b]返回:[/b] [Dictionary] 包含移动信息的字典
func _vec_input_2_toward() -> Dictionary:
	return {}

## 四向移动输入
## 
## 处理上下左右四个方向的离散移动输入。
## 同一时间只能向一个方向移动，优先级为：左→右→上→下。
## [br][br][b]返回:[/b] [Dictionary] 包含vec和pre_vec字段的移动信息
func _vec_input_4_toward() -> Dictionary:
	var vec_info : Dictionary = {}
	if Input.is_action_pressed("move_l"):
		vec_info["vec"] = Vector2.LEFT
	elif Input.is_action_pressed("move_r"):
		vec_info["vec"] = Vector2.RIGHT
	elif Input.is_action_pressed("move_u"):
		vec_info["vec"] = Vector2.UP
	elif Input.is_action_pressed("move_d"):
		vec_info["vec"] = Vector2.DOWN
	else:
		vec_info["vec"] = Vector2.ZERO
	if (!vec_info["vec"].is_zero_approx()):
		vec_info["pre_vec"] = vec_info["vec"]
	return vec_info

## 八向移动输入
## 
## 处理八个方向的离散移动输入，支持对角线移动。
## 使用符号函数将模拟输入转换为单位向量。
## [br][br][b]返回:[/b] [Dictionary] 包含vec和pre_vec字段的移动信息
func _vec_input_8_toward() -> Dictionary:
	var vec_info: Dictionary = {}
	vec_info["vec"] = Input.get_vector("move_l","move_r","move_u","move_d").sign()
	
	if (!vec_info["vec"].is_zero_approx()):
		vec_info["pre_vec"] = vec_info["vec"]
	return vec_info

## 全向移动输入
## 
## 处理连续的全方向移动输入，支持精确的模拟控制。
## 返回未经处理的原始输入向量，支持部分移动。
## [br][br][b]返回:[/b] [Dictionary] 包含vec和pre_vec字段的移动信息
func _vec_input_a_toward() -> Dictionary:
	var vec_info : Dictionary = {}
	vec_info["vec"] = Input.get_vector("move_l","move_r","move_u","move_d")
	
	if (!vec_info["vec"].is_zero_approx()):
		vec_info["pre_vec"] = vec_info["vec"]
	return vec_info
#endregion
