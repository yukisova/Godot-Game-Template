## 游戏主控制系统 - 管理玩家的输入信息逻辑与主要控制对象
## 负责玩家角色生成、定位、传送和伙伴管理等核心功能
## 支持多种移动模式并提供玩家输入的方向控制算法
## [br][b]编辑者:[/b] Sora
extends ISystem

enum PlayType {
	SINGLE, ## 单人模式，测试用
	DOUBLE, ## 双人模式，正常游戏用
}

## 默认游戏模式
var play_type: PlayType = PlayType.SINGLE

## 玩家定位信号
## [param target_level]: 目标关卡
## [param _context]: 定位上下文信息
signal player_located(target_level: Level, _context: Dictionary)

## 伙伴加入信号
## [param _partner]: 加入的伙伴实体
signal partner_joined(_partner: IEntity)

## 玩家场景资源
## 用于实例化玩家角色的预制场景
@export var player_scene: PackedScene
@export var player_scene_2: PackedScene

@export_subgroup("依赖")

## 输入监听器
## 处理玩家输入的组件
@export var input_listener: InputListener
@export var input_listener_2: InputListener

## 当前伙伴实体
## 当前活跃的伙伴角色
@export var partner: IEntity = null

## 玩家静态实体
## 持久化的玩家角色实体实例
var player_static: IEntity
## 双人模式下的第二个玩家角色实体，但是单人模式下，这个变量不应当被赋值
var player_static_2: IEntity

func _setup():

	partner_joined.connect(func(_partner: IEntity):
		if partner:
			partner.queue_free()
		partner = _partner
	)
	player_located.connect(_on_player_located)

## 处理玩家定位信号的回调函数
## [param target_level]: 目标关卡
## [param _context]: 定位上下文信息
func _on_player_located(target_level: Level, _context: Dictionary):
	match _context.get("type", "Initialize"):
		"Initialize":
			## 无论是单人还是双人，player_static都可以用来作为判断的标准
			if (player_static != null):
				player_static.reparent(target_level)
				player_static.global_position = _context["start_position"]
				player_static.main_control.global_position = _context["current_position"]
			else:
				var player_scene_path = _context.get("scene_file_path", null)
				var player_scene_path_2 = _context.get("scene_file_path_2", null)
				if player_scene_path != null:
					player_scene = load(player_scene_path)
				if player_scene_path_2 != null:
					player_scene_2 = load(player_scene_path_2)
				player_static = player_scene.instantiate()
				player_static.global_position = _context["start_position"]
				player_static.main_control.global_position = _context["current_position"]

				if play_type == PlayType.DOUBLE:
					player_static_2 = player_scene_2.instantiate()
					player_static_2.global_position = _context["start_position_2"]
					player_static_2.main_control.global_position = _context["current_position_2"]
					target_level.add_child(player_static_2)
					target_level.entity_count += 1 ## 目标的target_level新加了玩家，因此要进行额外的判断

				target_level.add_child(player_static)
			
			target_level.entity_count += 1 ## HACK 有点诡异的代码目标的target_level新加了玩家，因此要进行额外的判断
			
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
				if play_type == PlayType.DOUBLE:
					player_static_2.global_position = start_position + target_point.tranported_offset
					player_static_2.main_control.global_position = start_position + target_point.tranported_offset
				
			else:
				push_error("传送时未检测到玩家，请检查玩家配置")
				return
		_:
			push_error("未知的玩家初始化信息类型: %s" % _context.get("type", "Initialize"))
	
	SSignalBus.entity_initialize_started.emit()

#region 角色的主要移动方法(工具方法)

## 根据所需要获取的输入目标，对目标进行相关的映射
## [param entity: 角色实体]
## [br][br][b]返回:[/b] [SoraConstant.InputTarget] 输入目标
func get_input_target(entity: IEntity) -> SoraConstant.InputTarget:
	if entity == player_static:
		return SoraConstant.InputTarget.PLAYER1
	elif entity == player_static_2:
		return SoraConstant.InputTarget.PLAYER2
	else:
		return SoraConstant.InputTarget.COMMON

## 预留的双向移动控制方法
func _vec_input_2_toward(entity_input_target: SoraConstant.InputTarget) -> Dictionary:
	var prefix: String
	match entity_input_target:
		SoraConstant.InputTarget.PLAYER1:
			prefix = "player1_"
		SoraConstant.InputTarget.PLAYER2:
			prefix = "player2_"
		_:
			prefix = "common_"	
	
	return {
		"vec": Input.get_vector(prefix + "move_l", prefix + "move_r", prefix + "move_u", prefix + "move_d").sign(),
		"pre_vec": Input.get_vector(prefix + "move_l", prefix + "move_r", prefix + "move_u", prefix + "move_d")
	}

## 处理四个方向的离散移动输入
## 优先级为：左→右→上→下
func _vec_input_4_toward(entity_input_target: SoraConstant.InputTarget) -> Dictionary:
	var prefix: String
	match entity_input_target:
		SoraConstant.InputTarget.PLAYER1:
			prefix = "player1_"
		SoraConstant.InputTarget.PLAYER2:
			prefix = "player2_"
		_:
			prefix = "common_"

	var vec_info : Dictionary = {}
	if Input.is_action_pressed(prefix + "move_l"):
		vec_info["vec"] = Vector2.LEFT
	elif Input.is_action_pressed(prefix + "move_r"):
		vec_info["vec"] = Vector2.RIGHT
	elif Input.is_action_pressed(prefix + "move_u"):
		vec_info["vec"] = Vector2.UP
	elif Input.is_action_pressed(prefix + "move_d"):
		vec_info["vec"] = Vector2.DOWN
	else:
		vec_info["vec"] = Vector2.ZERO
	if (!vec_info["vec"].is_zero_approx()):
		vec_info["pre_vec"] = vec_info["vec"]
	return vec_info

## 处理八个方向的离散移动输入
## 支持对角线移动，使用符号函数转换
func _vec_input_8_toward(entity_input_target: SoraConstant.InputTarget) -> Dictionary:
	var prefix: String
	match entity_input_target:
		SoraConstant.InputTarget.PLAYER1:
			prefix = "player1_"
		SoraConstant.InputTarget.PLAYER2:
			prefix = "player2_"
		_:
			prefix = "common_"
	var vec_info: Dictionary = {}
	vec_info["vec"] = Input.get_vector(prefix + "move_l", prefix + "move_r", prefix + "move_u", prefix + "move_d").sign()
	
	if (!vec_info["vec"].is_zero_approx()):
		vec_info["pre_vec"] = vec_info["vec"]
	return vec_info

## 处理连续的全方向移动输入
## 支持精确的模拟控制和部分移动
func _vec_input_a_toward(entity_input_target: SoraConstant.InputTarget) -> Dictionary:
	var prefix: String
	match entity_input_target:
		SoraConstant.InputTarget.PLAYER1:
			prefix = "player1_"
		SoraConstant.InputTarget.PLAYER2:
			prefix = "player2_"
		_:
			prefix = "common_"
	var vec_info : Dictionary = {}
	vec_info["vec"] = Input.get_vector(prefix + "move_l", prefix + "move_r", prefix + "move_u", prefix + "move_d")
	
	if (!vec_info["vec"].is_zero_approx()):
		vec_info["pre_vec"] = vec_info["vec"]
	return vec_info
#endregion
